# -------------------------------------
# Custom utils for the test
# Designed by: Alex A. Taranov
# Support:     taransanya@pi-mezon.ru
# -------------------------------------

import os
import sys
import abc
import random
import vapicalls
import tqdm
import numpy
import uuid
import logging


def create_logger(name, filename):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    fh = logging.FileHandler(filename=filename, encoding='utf-8', mode='w')
    fh.setLevel(logging.DEBUG)
    ch = logging.StreamHandler(stream=sys.stdout)
    ch.setLevel(logging.INFO)
    fh.setFormatter(logging.Formatter("%(asctime)s: %(message)s"))
    ch.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(fh)
    logger.addHandler(ch)
    return logger


def mimetype_from_file_extension(filename):
    lower_filename = filename.lower()
    if '.png' in lower_filename:
        return 'image/png'
    if '.jpg' in lower_filename or '.jpeg' in lower_filename:
        return 'image/jpeg'
    if '.wav' in lower_filename:
        return 'audio/pcm'


# Base class to acquire biometric samples
class BiometricDataBase(abc.ABC):
    # should return next registration sample as a dict {label, name, bindata, mimetype}
    # label    - unique person's id across db i.e. same as 'template_id' in EBS identification API
    # name     - name of sample, can be arbitrary
    # bindata  - binary data i.e. sample content
    # mimetype - mimetype of data, for the instance image/jpeg, image/png or audio/pcm
    # or raise StopIteration
    def nextRegsample(self):
        pass

    # should return total number of registration samples in db
    def regsamplesTotal(self):
        pass

    # should return next sample as a dict {label, name, bindata, mimetype}
    # or raise StopIteration
    def nextSample(self):
        pass

    # should return total number of samples in db
    def samplesTotal(self):
        pass


# Derived class to work with local files data base
class LocalFilesDatabase(BiometricDataBase):
    def __init__(self, opt, securelog, logger):
        self.path = opt
        self.securelog = securelog
        if not os.path.exists(self.path):
            print(f"БД не найдена '{self.path}'. Отмена теста...")
            sys.exit(1)
        self.regsamples_files_list = []
        self.regsamples_pos = 0
        self.samples_files_list = []
        self.samples_pos = 0
        self.imposters_total = 0
        for subfoldername in [s.name for s in os.scandir(self.path) if s.is_dir()]:
            for filename in [f.name for f in os.scandir(os.path.join(self.path, subfoldername)) if f.is_file()]:
                if subfoldername != "imposters":
                    if filename[:2] == 'r_' or '_reg.' in filename:
                        self.regsamples_files_list.append((subfoldername, filename))
                    else:
                        self.samples_files_list.append((subfoldername, filename))
                else:
                    self.imposters_total += 1
                    self.samples_files_list.append((subfoldername, filename))
        random.shuffle(self.regsamples_files_list)
        random.shuffle(self.samples_files_list)
        logger.info("Найдено биометрических образцов:")
        logger.info(f" - регистрационных: {self.regsamplesTotal()}")
        logger.info(f" - верификационных: {self.samplesTotal()} (самозванцев: {self.imposters_total})")

    def regsamplesTotal(self):
        return len(self.regsamples_files_list)

    def samplesTotal(self):
        return len(self.samples_files_list)

    def nextRegsample(self):
        if self.regsamples_pos != len(self.regsamples_files_list):
            filepath = os.path.join(self.path,
                                    self.regsamples_files_list[self.regsamples_pos][0],
                                    self.regsamples_files_list[self.regsamples_pos][1])
            with open(filepath, 'rb') as f:
                bindata = f.read()
            self.regsamples_pos += 1
            return {'label': self.regsamples_files_list[self.regsamples_pos - 1][0],
                    'name': str(uuid.uuid4()) if self.securelog else
                    self.regsamples_files_list[self.regsamples_pos - 1][1],
                    'bindata': bindata,
                    'mimetype': mimetype_from_file_extension(self.regsamples_files_list[self.regsamples_pos - 1][1])}
        else:
            raise StopIteration

    def nextSample(self):
        if self.samples_pos != len(self.samples_files_list):
            filepath = os.path.join(self.path,
                                    self.samples_files_list[self.samples_pos][0],
                                    self.samples_files_list[self.samples_pos][1])
            with open(filepath, 'rb') as f:
                bindata = f.read()
            self.samples_pos += 1
            return {'label': self.samples_files_list[self.samples_pos - 1][0],
                    'name': str(uuid.uuid4()) if self.securelog else self.samples_files_list[self.samples_pos - 1][1],
                    'bindata': bindata,
                    'mimetype': mimetype_from_file_extension(self.samples_files_list[self.samples_pos - 1][1])}
        else:
            raise StopIteration


def extract(db, apiurl, logger, registration):
    extract_errors = []
    extract_times = []
    templates = []
    template_size_bytes = 0
    progress_bar = tqdm.tqdm(total=db.regsamplesTotal() if registration else db.samplesTotal(), file=sys.stdout)
    while True:
        try:
            if registration:
                sample = db.nextRegsample()
            else:
                sample = db.nextSample()
            extract_status_code, extract_response_data, extract_duration = vapicalls.extract(apiurl, sample, logger)
            if extract_status_code != 200:
                extract_errors.append(extract_response_data)
            else:
                template_size_bytes = max(len(extract_response_data), template_size_bytes)
                extract_times.append(extract_duration)
                templates.append({"template_id": sample['label'], "bindata": extract_response_data})
        except StopIteration:
            break
        else:
            progress_bar.update(1)
    progress_bar.close()
    if registration:
        logger.info(f" - отказов регистрации: {len(extract_errors)}")
    else:
        logger.info(f" - отказов сбора данных: {len(extract_errors)}")
    random.shuffle(templates)
    return templates, extract_errors, extract_times, template_size_bytes


def compare(etemplates, vtemplates, apiurl, logger):
    compare_errors = []
    compare_times = []
    mate_comparisons = []
    non_mate_comparisons = []

    from threading import Thread, Lock

    results_mutex = Lock()
    counters_mutex = Lock()
    pos = {"e": 0, "v": 0}

    def work(etotal, vtotal):
        while True:
            counters_mutex.acquire()
            if pos["e"] >= etotal:
                counters_mutex.release()
                break
            e = pos["e"]
            v = pos["v"]
            pos["v"] += 1
            if pos["v"] == vtotal:
                pos["e"] += 1
                pos["v"] = 0
            counters_mutex.release()
            status_code, response_data, duration = vapicalls.compare(apiurl, etemplates[e], vtemplates[v], logger)
            results_mutex.acquire()
            if status_code != 200:
                compare_errors.append(response_data)
                if status_code == 0:
                    results_mutex.release()
                    break
            else:
                compare_times.append(duration)
                if etemplates[e]["template_id"] == vtemplates[v]["template_id"]:
                    mate_comparisons.append(response_data["score"])
                else:
                    non_mate_comparisons.append(response_data["score"])
            progress_bar.update(1)
            results_mutex.release()

    threads = []
    parallel_threads = int(os.getenv('COMPARISION_THREADS', 1))
    logger.info(f" - сравнение, число параллельных потоков: {parallel_threads}")
    logger.debug(" * для экономии дискового пространства во время сравнения логироваться будут только ошибки")
    progress_bar = tqdm.tqdm(total=len(vtemplates) * len(etemplates), file=sys.stdout)
    for i in range(parallel_threads):
        tread = Thread(target=work, args=(len(etemplates), len(vtemplates)))
        tread.start()
        threads.append(tread)

    for thread in threads:
        thread.join()

    progress_bar.close()
    logger.info(f" - отказов: {len(compare_errors)}")
    return mate_comparisons, non_mate_comparisons, compare_errors, compare_times


def statistic_moments(vector, multiplier):
    if len(vector) > 0:
        arr = numpy.asarray(vector, dtype=numpy.float32)
        mean = numpy.average(arr)
        mean_of_square = numpy.dot(arr, arr) / arr.size
        return {
            "avg": mean * multiplier,
            "std": numpy.sqrt(mean_of_square - mean * mean) * multiplier if len(vector) > 1 else None,
            "min": arr.min() * multiplier,
            "max": arr.max() * multiplier,
            "med": numpy.median(arr) * multiplier
        }
    return {
        "avg": None,
        "std": None,
        "min": None,
        "max": None,
        "med": None
    }


def prob_estimation(positive_outcomes, total_outcomes, reliable_threshold=3):
    if total_outcomes < reliable_threshold:
        return None
    if reliable_threshold < positive_outcomes <= (total_outcomes - reliable_threshold):
        return positive_outcomes / total_outcomes
    elif positive_outcomes > (total_outcomes - reliable_threshold):
        return (total_outcomes - reliable_threshold) / total_outcomes
    return reliable_threshold / total_outcomes


def prob_stdev(positive_outcomes, total_outcomes, reliable_threshold=6):
    if total_outcomes < reliable_threshold:
        return None
    if positive_outcomes > (total_outcomes - reliable_threshold):
        positive_outcomes = (total_outcomes - reliable_threshold)
    elif positive_outcomes < reliable_threshold:
        positive_outcomes = reliable_threshold
    p = positive_outcomes / total_outcomes
    return (p * (1 - p) / total_outcomes)**0.5


def calculate_curves(mate_comparisons, non_mate_comparisons, logger, steps_total=1E4, epsilon=1.0E-6):
    logger.info(f" - сравнений зарегистрированных пользователей: {len(mate_comparisons)}")
    logger.info(f" - сравнений незарегистрированных пользователей: {len(non_mate_comparisons)}")
    logger.info("\nРасчёт кривой КОО:")
    progress_bar = tqdm.tqdm(total=int(steps_total), file=sys.stdout)
    numpy_mates = numpy.asarray(mate_comparisons)
    numpy_nonmates = numpy.asarray(non_mate_comparisons)
    roc = []
    for similarity_threshold in numpy.linspace(start=0.0 - epsilon, stop=1.0 + epsilon, num=int(steps_total)):
        false_negative_verifications = numpy.sum(numpy_mates < similarity_threshold)
        false_positive_verifications = numpy.sum(numpy_nonmates >= similarity_threshold)
        roc.append({'s': similarity_threshold,
                    'ВЛНС': prob_estimation(false_negative_verifications, len(mate_comparisons)),
                    'ВЛНС_stdev': prob_stdev(false_negative_verifications, len(mate_comparisons)),
                    'ВЛС': prob_estimation(false_positive_verifications, len(non_mate_comparisons)),
                    'ВЛС_stdev': prob_stdev(false_positive_verifications, len(non_mate_comparisons))})
        progress_bar.update(1)
    progress_bar.close()
    logger.info(" - расчёт окончен")
    return roc


def process(mate_comparisons, non_mate_comparisons, compare_errors, compare_times,
            extract_errors, extract_times, template_size_bytes,
            registration_errors, registration_times, reg_template_size_bytes,
            logger):
    samples_total = len(extract_errors) + len(extract_times)
    reg_samples_total = len(registration_errors) + len(registration_times)
    results = {
        "Подробно": {
            "Отказов регистрации": len(registration_errors),
            "Транзакций регистрации": reg_samples_total,
            "Отказов сбора данных": len(extract_errors),
            "Транзакций сбора данных": samples_total,
            "Транзакций сравнения": len(compare_errors) + len(compare_times),
            "Отказов сравнения": len(compare_errors)
        },
        "Вероятность отказа регистрации": prob_estimation(len(registration_errors), reg_samples_total),
        "ВОР_stdev": prob_stdev(len(registration_errors), reg_samples_total),
        "Вероятность отказа сбора данных": prob_estimation(len(extract_errors), samples_total),
        "ВОСД_stdev": prob_stdev(len(extract_errors), samples_total),
        "Размер биометрического контрольного шаблона": reg_template_size_bytes,
        "Размер биометрического шаблона": template_size_bytes,
        "Длительность сравнения": statistic_moments(compare_times, 1000),
        "Длительность сбора данных": statistic_moments(extract_times, 1000),
        "Длительность регистрации": statistic_moments(registration_times, 1000),
        "Кривая КОО": calculate_curves(mate_comparisons, non_mate_comparisons, logger)}
    return results
