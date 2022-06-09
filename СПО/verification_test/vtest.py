# ------------------------------------------------
# Main script of ROSTELECOM's verification test
# Designed by: Alex A. Taranov
# Support:     taransanya@pi-mezon.ru
# ------------------------------------------------

import vapicalls
import argparse
import vutils
import json
import sys
import os
import subprocess
import loadmonitor
from cpuinfo import get_cpu_info
from datetime import datetime

argparser = argparse.ArgumentParser(description='Технологический тест API БП верификации')
argparser.add_argument('--hosturl', default='http://localhost:5000', help='URL хоста')
argparser.add_argument('--urlprefix', default='', help='Префикс базового URL доступа к API')
argparser.add_argument('--modality', default='face', help='Модальность БП')
argparser.add_argument('--vendor', default='unknown', help='Наименование вендора')
argparser.add_argument('--version', default='v1', help='Версия БП')
argparser.add_argument('--dbopt', default='./data', help='Опции подключения к БД')
argparser.add_argument('--resultspath', default='./results', help='Путь для хранения результов')
argparser.add_argument('--dsize', default=None, type=int, help='Размер дистрибутива БП, байт')
argparser.add_argument('--securelog', action='store_true', help='Заменять имена файлов в лог-файле на случайные guid-ы')
argparser.add_argument('--envcontrol', action='store_true', help='Использовать переменные окружения вместо аргументов')
args = argparser.parse_args()

if args.envcontrol:
    args.dbopt = os.getenv('VT_DB_OPT', './data')
    args.vendor = os.getenv('VT_API_VENDOR', 'unknown')
    args.version = os.getenv('VT_API_VERSION', 'v1')
    args.modality = os.getenv('VT_API_MODALITY', 'face')
    args.hosturl = os.getenv('VT_HOST_URL', 'http://localhost:5000')
    args.urlprefix = os.getenv('VT_URL_PREFIX', '')
    args.resultspath = os.getenv('VT_RESULTS_PATH', './results')
    args.dsize = int(os.getenv('VT_DISTRIB_SIZE', None))

begindt = datetime.now().strftime('%d.%m.%Y %H:%M:%S')

print("Проверка наличия пути для сохранения результатов:")
if not os.path.exists(args.resultspath):
    print(f" - попытка создания пути {args.resultspath}")
    os.makedirs(args.resultspath)
    if not os.path.exists(args.resultspath):
        print(f"Не удаётся создать путь {args.resultspath}. Отмена теста...")
        sys.exit(1)
print(" - путь существует")

print("\nЗапуск мониторинга нагрузки на систему:")
try:
    load_monitor_proc = subprocess.Popen(['python3', 'loadmonitor.py'], stdout=subprocess.PIPE)
except FileNotFoundError as ex:
    load_monitor_proc = subprocess.Popen(['python', 'loadmonitor.py'], stdout=subprocess.PIPE)
print(" - мониторинг запущен")

print("\nСоздание лог-файла:")
log_filename = f"{args.resultspath}/v_{args.vendor}_{args.version}.log"
logger = vutils.create_logger(name="vtest", filename=log_filename)
print(f" - '{log_filename}'")

apiurl = f"{args.hosturl}{args.urlprefix}"
# if args.urlprefix == '':
#    apiurl = f"{args.hosturl}/{args.version}/{args.modality}/pattern"
# else:
#    apiurl = f"{args.hosturl}{args.urlprefix}"

logger.info("\nТест запущен с параметрами:")
logger.info(f" - БД:          {args.dbopt}")
logger.info(f" - вендор:      {args.vendor}")
logger.info(f" - модальность: {args.modality}")
logger.info(f" - версия:      {args.version}")
logger.info(f" - URL:         {apiurl}")
logger.info(f" - Результаты:  {args.resultspath}")

logger.info("\nПроверка исправности БП:")
health_status_code, health_json, health_duration = vapicalls.health(apiurl, logger)

logger.info("\nПодключение к БД:")
db = vutils.LocalFilesDatabase(args.dbopt, args.securelog, logger)

logger.info("\nИзвлечение регистрационных шаблонов:")
reg_templates, reg_errors, reg_times, reg_template_size_bytes = vutils.extract(db, apiurl, logger, True)
logger.info(f" - размер биометрического контрольного шаблона: {reg_template_size_bytes} байт")

logger.info("\nИзвлечение верификационных шаблонов:")
templates, extract_errors, extract_times, template_size_bytes = vutils.extract(db, apiurl, logger, False)
logger.info(f" - размер биометрического шаблона: {template_size_bytes} байт")

logger.info("\nСравнение (верификация):")
mate_comparisons, non_mate_comparisons, compare_errors, compare_times = vutils.compare(reg_templates, templates,
                                                                                       apiurl, logger)

logger.info("\nОбработка измерений:")
results = vutils.process(mate_comparisons, non_mate_comparisons, compare_errors, compare_times,
                         extract_errors, extract_times, template_size_bytes,
                         reg_errors, reg_times, reg_template_size_bytes,
                         logger)

logger.info("\nСохранение результатов:")
try:
    out, err = load_monitor_proc.communicate(timeout=0)
except subprocess.TimeoutExpired:
    load_monitor_proc.kill()
    out, err = load_monitor_proc.communicate()
cpu_usage, mem_usage = loadmonitor.output2json(out)
results["Дополнительно"] = {
    "Дата и время окончания испытаний": datetime.now().strftime('%d.%m.%Y %H:%M:%S'),
    "Дата и время начала испытаний": begindt,
    "Наименование вендора": args.vendor,
    "Наименование версии": args.version,
    "Размер дистрибутива": args.dsize,
    "Модель ЦПУ": get_cpu_info()['brand_raw'],
    "Использование ЦПУ": vutils.statistic_moments(cpu_usage, 1.0),
    "Использование оперативной памяти": vutils.statistic_moments(mem_usage, 1.0)
}

filename = f"{args.resultspath}/v_{args.vendor}_{args.version}.json"
with open(filename, "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=4)
    logger.info(f" - результаты сохранены в '{filename}'")

filename = f"{args.resultspath}/fmr_{args.vendor}_{args.version}.csv"
with open(filename, 'w', encoding='utf-8') as csv_file:
    step = 0.001
    similarity_score = 0.0
    epsilon = step / 10
    for item in results["Кривая КОО"]:
        if (similarity_score - item["s"]) <= epsilon:
            csv_file.write(f"{similarity_score:.3f};{item['ВЛС']}\n")
            similarity_score += step
    logger.info(f" - таблица зависимости ВЛС от степени схожести сохранена в '{filename}'")

filename = f"{args.resultspath}/fnmr_{args.vendor}_{args.version}.csv"
with open(filename, 'w', encoding='utf-8') as csv_file:
    step = 0.001
    similarity_score = 0.0
    epsilon = step / 10
    for item in results["Кривая КОО"]:
        if (similarity_score - item["s"]) <= epsilon:
            csv_file.write(f"{similarity_score:.3f};{item['ВЛНС']}\n")
            similarity_score += step
    logger.info(f" - таблица зависимости ВЛНС от степени схожести сохранена в '{filename}'")

try:
    p = subprocess.run(['python3',
                        'vjson2csv.py',
                        '--json', f"{args.resultspath}/v_{args.vendor}_{args.version}.json",
                        '--out_path', args.resultspath], capture_output=True)
    print(p.stdout.decode())
except FileNotFoundError as ex:
    p = subprocess.run(['python',
                        'vjson2csv.py',
                        '--json', f"{args.resultspath}/v_{args.vendor}_{args.version}.json",
                        '--out_path', args.resultspath], capture_output=True)
    print(p.stdout.decode())
