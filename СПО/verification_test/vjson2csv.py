import argparse
import json
import os
import sys
import vdrawutils
import numpy

argparser = argparse.ArgumentParser(description='Скрипт конвертации результатов теста в данные для web-формы')
argparser.add_argument('--json', default='', help='Имя json-файла для преобразования')
argparser.add_argument('--out_path', default='./results', help='Путь для сохранения данных')
args = argparser.parse_args()

if args.json == '':
    print("Не указан файл для преобразования! Отмена...")
    sys.exit(1)

if not os.path.exists(args.json):
    print(f"Файл '{args.json}' не найден на диске! Отмена...")
    sys.exit(2)

acc_vocab = {
    "Разработчик": "Дополнительно/Наименование вендора",
    "Алгоритм": "Дополнительно/Наименование версии",
    "Версия алгоритма": "Дополнительно/Наименование версии",
    "Дата заявки на испытания": "Дополнительно/Дата и время начала испытаний",
    "EER (равновероятностая ошибка)": None,
    "ВЛНС@ВЛС=1E-6": None,
    "ВЛНС@ВЛС=1E-4": None,
    "ВОР": "Вероятность отказа регистрации",
    "ВОСД": "Вероятность отказа сбора данных",
}

res_vocab = {
    "Разработчик": "Дополнительно/Наименование вендора",
    "Алгоритм": "Дополнительно/Наименование версии",
    "Версия алгоритма": "Дополнительно/Наименование версии",
    "Дата заявки на испытания": "Дополнительно/Дата и время начала испытаний",
    "Размер дистрибутива (Мбайт)": "Дополнительно/Размер дистрибутива",
    "Использование процессора (%)": "Дополнительно/Использование ЦПУ",
    "Максимальное потребление оперативной памяти (Мбайт)": "Дополнительно/Использование оперативной памяти",
    "Размер шаблона (байт)": "Размер биометрического шаблона",
    "Длительность создания шаблона (мс)": "Длительность сбора данных",
    "Длительность сравнения (мс)": "Длительность сравнения"
}

name = args.json.split('v_', 1)[1].split('.json', 1)[0]
roc_filename = f"{args.out_path}/v_ROC_{name}.csv"
acc_filename = f"{args.out_path}/v_ACC_{name}.csv"
res_filename = f"{args.out_path}/v_RES_{name}.csv"
with open(args.json, 'r', encoding='utf-8') as json_file, \
        open(roc_filename, 'w', encoding='utf-8') as roc_file, \
        open(acc_filename, 'w', encoding='utf-8') as acc_file, \
        open(res_filename, 'w', encoding='utf-8') as res_file:
    # METADATA
    normal_percentile = 1.959963984540054
    probs_precision = int(numpy.round(numpy.log10(json_data['Подробно']['Транзакций регистрации'] - json_data['Подробно']['Отказов регистрации'])))
    fmr_precision = int(numpy.round(numpy.log10(json_data['Подробно']['Транзакций сравнения'] - json_data['Подробно']['Отказов сравнения'])))
    # ROC TABLE
    json_data = json.load(json_file)
    roc_file.write("similarity,ВЛС,ВЛНС")
    for item in json_data["Кривая КОО"]:
        roc_file.write(f"\n{vdrawutils.float2str(item['s'], 4)},{vdrawutils.float2str(item['ВЛС'], fmr_precision)},{vdrawutils.float2str(item['ВЛНС'], probs_precision)}")
    print(f" - таблица значений кривой КОО сохранена в '{roc_filename}'", flush=True)
    
    # ACCURACY TABLE
    acc_list = []
    for key in acc_vocab:
        name = acc_vocab[key]
        if name is not None:
            if 'Дополнительно/' in name:
                sub_key = name.split('Дополнительно/', 1)[1]
                if 'Дата' in sub_key:
                    acc_list.append(json_data['Дополнительно'][sub_key].split(' ', 1)[0])
                else:
                    acc_list.append(json_data['Дополнительно'][sub_key])
            elif name == 'Вероятность отказа регистрации':
                prob = json_data[name]
                stdev = json_data['ВОР_stdev']
                tmp = f"{vdrawutils.float2str(prob, probs_precision)} ± " \
                      f"{vdrawutils.float2str(normal_percentile * stdev, probs_precision) if stdev is not None else None}"
                acc_list.append(tmp)
            elif name == 'Вероятность отказа сбора данных':
                prob = json_data[name]
                stdev = json_data['ВОСД_stdev']
                tmp = f"{vdrawutils.float2str(prob, probs_precision)} ± " \
                      f"{vdrawutils.float2str(normal_percentile * stdev, probs_precision) if stdev is not None else None}"
                acc_list.append(tmp)
        elif 'ВЛНС@ВЛС' in key:
            fnmr, stdev = vdrawutils.findFNMR(float(key.split('=', 1)[1]), json_data['Кривая КОО'])
            tmp = f"{vdrawutils.float2str(fnmr, probs_precision)} ± " \
                  f"{vdrawutils.float2str(normal_percentile * stdev, probs_precision) if stdev is not None else None}"
            acc_list.append(tmp)
        elif 'EER' in key:
            err, stdev = vdrawutils.findERR(json_data['Кривая КОО'])
            tmp = f"{vdrawutils.float2str(err, probs_precision)} ± " \
                  f"{vdrawutils.float2str(normal_percentile * stdev, probs_precision) if stdev is not None else None}"
            acc_list.append(tmp)
    acc_file.write(f"{','.join(acc_vocab.keys())}\n{','.join(acc_list)}")
    print(f" - таблица точностных характеристик сохранена в '{acc_filename}'", flush=True)
    # RESOURCES TABLE
    res_list = []
    for key in res_vocab:
        name = res_vocab[key]
        if 'Дополнительно/' in name:
            sub_key = name.split('Дополнительно/', 1)[1]
            if 'Дата' in sub_key:
                res_list.append(json_data['Дополнительно'][sub_key].split(' ', 1)[0])
            elif sub_key == 'Размер дистрибутива':
                value = json_data['Дополнительно'][sub_key] / (1024 ** 2)
                res_list.append(vdrawutils.float2str(value, 0))
            elif sub_key == 'Использование ЦПУ':
                value = json_data['Дополнительно'][sub_key]['avg'] if json_data['Дополнительно'][sub_key][
                                                                          'avg'] is not None else None
                stdev = json_data['Дополнительно'][sub_key]['std'] if json_data['Дополнительно'][sub_key][
                                                                          'std'] is not None else None
                tmp = f"{vdrawutils.float2str(value, 0)} ± " \
                      f"{vdrawutils.float2str(normal_percentile * stdev, 0) if stdev is not None else None}"
                res_list.append(tmp)
            elif sub_key == 'Использование оперативной памяти':
                value = json_data['Дополнительно'][sub_key]['avg'] / (1024 ** 2) if json_data['Дополнительно'][sub_key][
                                                                                        'avg'] is not None else None
                stdev = json_data['Дополнительно'][sub_key]['std'] / (1024 ** 2) if json_data['Дополнительно'][sub_key][
                                                                                        'std'] is not None else None
                tmp = f"{vdrawutils.float2str(value, 0)} ± " \
                      f"{vdrawutils.float2str(normal_percentile * stdev, 0) if stdev is not None else None}"
                res_list.append(tmp)
            else:
                res_list.append(json_data['Дополнительно'][sub_key])
        elif name == 'Размер биометрического шаблона':
            res_list.append(str(json_data[name]))
        elif name == 'Длительность сбора данных':
            value = json_data[name]['avg']
            stdev = json_data[name]['std']
            tmp = f"{vdrawutils.float2str(value, 1)} ± " \
                  f"{vdrawutils.float2str(normal_percentile * stdev, 1) if stdev is not None else None}"
            res_list.append(tmp)
        elif name == 'Длительность сравнения':
            value = json_data[name]['avg']
            stdev = json_data[name]['std']
            tmp = f"{vdrawutils.float2str(value, 1)} ± " \
                  f"{vdrawutils.float2str(normal_percentile * stdev, 1) if stdev is not None else None}"
            res_list.append(tmp)
    res_file.write(f"{','.join(res_vocab.keys())}\n{','.join(res_list)}")
    print(f" - таблица ресурсных характеристик сохранена в '{res_filename}'", flush=True)
