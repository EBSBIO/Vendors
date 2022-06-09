# -------------------------------------
# Utils for the results visualization
# Designed by: Alex A. Taranov
# Support:     taransanya@pi-mezon.ru
# -------------------------------------

from IPython.display import display
import matplotlib.pyplot as plt
import pandas as pd
import json
import os
import numpy
from scipy import stats


def findFNMR(targetFMR, roc_pts):
    if roc_pts[0]['ВЛС'] is None:
        return None, None
    for i in range(0, len(roc_pts) - 1):
        if (roc_pts[i]['ВЛС'] - targetFMR) * (roc_pts[i + 1]['ВЛС'] - targetFMR) <= 0:
            stdev = None
            if roc_pts[i]['ВЛНС_stdev'] is not None and roc_pts[i + 1]['ВЛНС_stdev'] is not None:
                stdev = roc_pts[i]['ВЛНС_stdev'] + roc_pts[i + 1]['ВЛНС_stdev']
            return roc_pts[i]['ВЛНС'] + (roc_pts[i]['ВЛС'] - targetFMR) * \
                   (roc_pts[i + 1]['ВЛНС'] - roc_pts[i]['ВЛНС']) / (roc_pts[i]['ВЛС'] - roc_pts[i + 1]['ВЛС']), stdev
    return roc_pts[len(roc_pts) - 1]['ВЛНС'], roc_pts[len(roc_pts) - 1]['ВЛНС_stdev']


def findERR(roc_pts):
    index = 0
    for i in range(0, len(roc_pts)):
        index = i
        if (roc_pts[i]['ВЛС'] - roc_pts[i]['ВЛНС']) <= 0:
            break
    stdev = None
    if roc_pts[index]['ВЛС_stdev'] is not None and roc_pts[index]['ВЛНС_stdev'] is not None:
        stdev = roc_pts[index]['ВЛС_stdev'] + roc_pts[index]['ВЛНС_stdev']
    return (roc_pts[index]['ВЛС'] + roc_pts[index]['ВЛНС']) / 2.0, stdev


def acronim(name):
    words = name.split()
    if len(words) > 1:
        return ''.join((w[0].upper() if w[:2] != 'не' else ('Н' + w[2].upper())) for w in words)
    return words[0]


def far(fmr, ftar):
    if fmr is None:
        return None
    if ftar is None:
        return None
    return fmr * (1 - ftar)


def frr(fnmr, ftar):
    if fnmr is None:
        return None
    if ftar is None:
        return None
    return ftar + fnmr * (1 - ftar)


def gfar(fmr, ftar, fter):
    if fmr is None:
        return None
    if ftar is None:
        return None
    if fter is None:
        return None
    return far(fmr, ftar) * (1 - fter)


def gfrr(fnmr, ftar, fter):
    if fnmr is None:
        return None
    if ftar is None:
        return None
    if fter is None:
        return None
    return fter + (1 - fter) * frr(fnmr, ftar)


def float2str(value: float, precision: int) -> str:
    if value is None:
        return 'None'
    if precision == 0:
        return str(int(round(value, precision)))
    tmp = f"{{:.{precision}f}}"
    return tmp.format(round(value, precision))


def makeTable(path, name_filter='', conf_lvl=0.05):
    normal_percentile = stats.norm.ppf(1.0 - conf_lvl / 2)
    list_of_protocols = [f.name for f in os.scandir(path) if f.is_file()]
    dictionary = {}
    acronims = {"ВЛС":  "Вероятность ложного совпадения",
                "ВЛНС": "Вероятность ложного несовпадения",
                "[...]": f"{(1.0 - conf_lvl) * 100} %-ный доверительный интервал"}
    target_fmrs = [1E-2, 1E-4, 1E-6]
    for filename in list_of_protocols:
        if '.json' in filename and name_filter in filename:
            with open(os.path.join(path, filename), encoding="utf8") as f:
                data = json.load(f)
                data["Наименование"] = filename.rsplit('.json', 1)[0].split('v_', 1)[1]
                float_precision = int(numpy.round(numpy.log10(data['Подробно']['Транзакций регистрации'])))
                data["[ВОР]"] = f"{float2str(data['Вероятность отказа регистрации'], float_precision)} ± " \
                                f"{float2str(normal_percentile * data['ВОР_stdev'], float_precision) if data['ВОР_stdev'] is not None else None}"
                data["[ВОСД]"] = f"{float2str(data['Вероятность отказа сбора данных'], float_precision)} ± " \
                                 f"{float2str(normal_percentile * data['ВОСД_stdev'], float_precision) if data['ВОСД_stdev'] is not None else None}"
                for target_fmr in target_fmrs:
                    fnmr, stdev = findFNMR(target_fmr, data['Кривая КОО'])
                    data[f"ВЛНС@{target_fmr:.0e}"] = fnmr
                    data[f"[ВЛНС@{target_fmr:.0e}]"] = f"{float2str(fnmr, float_precision)} ± " \
                                                       f"{float2str(normal_percentile * stdev, float_precision) if stdev is not None else None}"
                    data["Вероятность ложного допуска"] = far(target_fmr, data["Вероятность отказа сбора данных"])
                    data["Обобщённая вероятность ложного допуска"] = gfar(target_fmr, data["Вероятность отказа сбора данных"],
                                                                          data["Вероятность отказа регистрации"])
                    data["Вероятность ложного недопуска"] = frr(fnmr, data["Вероятность отказа сбора данных"],)
                    data["Обобщённая вероятность ложного недопуска"] = gfrr(fnmr, data["Вероятность отказа сбора данных"],
                                                                            data["Вероятность отказа регистрации"])
                prob, stdev = findERR(data['Кривая КОО'])
                data["Равновероятностная ошибка"] = prob
                data["[РО]"] = f"{float2str(prob, float_precision)} ± " \
                               f"{float2str(normal_percentile * stdev, float_precision) if stdev is not None else None}"
                float_precision = 1
                data["[ДР,мс]"] = f"{float2str(data['Длительность регистрации']['avg'], float_precision)} ± " \
                                  f"{float2str(normal_percentile * data['Длительность регистрации']['std'], float_precision) if data['Длительность регистрации']['std'] is not None else None}"
                data["[ДСД,мс]"] = f"{float2str(data['Длительность сбора данных']['avg'], float_precision)} ± " \
                                   f"{float2str(normal_percentile * data['Длительность сбора данных']['std'], float_precision) if data['Длительность сбора данных']['std'] is not None else None}"
                data["[ДС,мс]"] = f"{float2str(data['Длительность сравнения']['avg'], float_precision)} ± " \
                                  f"{float2str(normal_percentile * data['Длительность сравнения']['std'], float_precision) if data['Длительность сравнения']['std'] is not None else None}"
                for key in data:
                    if 'Длительность' in key:
                        tmpkey = acronim(key)
                        if tmpkey != key and tmpkey not in acronims:
                            acronims[tmpkey] = key
                        tmpkey += ',мс'
                        if tmpkey not in dictionary:
                            dictionary[tmpkey] = [data[key]["avg"]]
                        else:
                            dictionary[tmpkey].append(data[key]["avg"])
                    elif key not in ['Кривая КОО', 'Подробно', 'Дополнительно']:
                        tmpkey = acronim(key)
                        if tmpkey != key and tmpkey not in acronims:
                            acronims[tmpkey] = key
                        if 'Размер' in key:
                            tmpkey += ',байт'
                        if tmpkey not in dictionary:
                            dictionary[tmpkey] = [data[key]]
                        else:
                            dictionary[tmpkey].append(data[key])

    df = pd.DataFrame(data=dictionary)
    df.set_index("Наименование", inplace=True)
    acronims_keys = []
    acronims_names = []
    acronims["None"] = "Недостаточно измерений для достоверной оценки"
    for key in sorted(acronims):
        acronims_keys.append(key)
        acronims_names.append(acronims[key])
    adf = pd.DataFrame(data={"Обозначение": acronims_keys, "Наименование": acronims_names})
    adf.set_index("Обозначение", inplace=True)
    return df, adf


def drawTables(tables, cols):
    ci_cols = []
    for name in cols:
        if 'байт' not in name:
            ci_cols.append(f"[{name}]")
        else:
            ci_cols.append(name)
    display(tables.sort_values(by=cols)[ci_cols])


def drawROC(path, name_filter='', axis_limits=[1E-4, 1E-0, 1E-4, 1E-0]):
    list_of_protocols = [f.name for f in os.scandir(path) if f.is_file()]
    curve_num = 0
    linestyles_list = ['-', '--', '-.', ':']
    plt.rcParams.update({'font.size': 15})
    for filename in list_of_protocols:
        if '.json' in filename and name_filter in filename:
            with open(os.path.join(path, filename), encoding="utf8") as f:
                data = json.load(f)
                fmr = []
                fnmr = []
                for point in data['Кривая КОО']:
                    fmr.append(point['ВЛС'])
                    fnmr.append(point['ВЛНС'])
                plt.plot(fmr,
                         fnmr,
                         label=filename.rsplit('.json', 1)[0].split('v_', 1)[1],
                         linestyle=linestyles_list[curve_num % len(linestyles_list)])
                curve_num += 1

    plt.ylabel('ВЛНС')
    plt.yscale('log')
    plt.xlabel('ВЛС')
    plt.xscale('log')
    plt.grid(True, which='both', alpha=0.75)
    plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc='lower left', ncol=4, mode="expand", borderaxespad=0.)
    fig = plt.gcf()
    fig.set_size_inches(18.5, 14.5)
    ax = plt.gca()
    ax.set_facecolor('#F0F0F0')
    plt.axis(axis_limits)


def drawWC(path, name_filter=''):
    list_of_protocols = [f.name for f in os.scandir(path) if f.is_file()]
    plt.rcParams.update({'font.size': 15})
    for filename in list_of_protocols:
        if '.json' in filename and name_filter in filename:
            with open(os.path.join(path, filename), encoding="utf8") as f:
                data = json.load(f)
                fmr = []
                fnmr = []
                st = []
                for point in data['Кривая КОО']:
                    fmr.append(point['ВЛС'])
                    fnmr.append(point['ВЛНС'])
                    st.append(point['s'])

                fig, ax1 = plt.subplots()
                color = 'tab:red'
                ax1.set_ylabel('ВЛС', color=color)
                ax1.set_xlabel('score threshold')
                ax1.tick_params(axis='y', labelcolor=color)
                ax1.plot(st, fmr, label=filename.rsplit('.json', 1)[0], color=color)
                color = 'tab:blue'
                ax2 = plt.twinx()
                ax2.set_ylabel('ВЛНС', color=color)
                ax2.tick_params(axis='y', labelcolor=color)
                plt.plot(st, fnmr, label=filename.rsplit('.json', 1)[0], color=color)
                plt.xlabel('score threshold')
                ax1.grid(True, alpha=0.75)
                # ax1.legend()
                # ax2.legend()
                plt.title(filename.split('.json', 1)[0].split('v_', 1)[1])
                fig = plt.gcf()
                fig.set_size_inches(18.5, 8)
                ax = plt.gca()
                ax1.set_facecolor('#F0F0F0')
                ax1.axis([0, 1E-0, -0.05, 1.05E-0])
                ax2.axis([0, 1E-0, -0.05, 1.05E-0])
                ax1.locator_params(nbins=10)
                ax2.locator_params(nbins=10)
                fig.tight_layout()
