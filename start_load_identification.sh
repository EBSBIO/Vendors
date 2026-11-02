#!/bin/bash

# ================================================================================
# DESC:    скрипт запуска нагрузочных тестов API identification посредством jmeter
# VERSION: 1.1.1
# ================================================================================

##### настройки среды и глобальные параметры
source include/common/f_config.sh
source include/common/f_validate_input_params.sh
source include/common/f_print_test_version.sh

CURRENT_FILE_PATH="${BASH_SOURCE[0]}"

f_print_usage() {
  echo "Использование: $0 [OPTIONS] TASK_NAME METHOD THREADS ENDPOINT DURATION
    
OPTIONS:
  -d          режим очистки ненужных данных
  -b          запуск в фоновом режиме (screen)
  -t  string  тип тест-кейсов (выберите одно из значений): sound, photo (по умолчанию)
  -s  string  абсолютный путь к директории, в которой находятся образцы для тестирования
  -a  string  версия API (по умолчанию \"v1\")
  -p  string  префикс (необязательная составная часть пути)
  -r  int     период ramp-up, сек (по умолчанию 0)
  
TASK_NAME  string  наименование вендора
METHOD     string  выбор метода (выберите одно из значений): extract, add, update, delete, match, identify
THREADS    int     количество потоков нагрузки
ENDPOINT   string  <IP/DNS>:<ПОРТ>
DURATION   int     длительность теста, сек"
}

rm_templates() {
        local IFS=$'\n'
        while [ -n "$1" ]; do
            rm -f $(find $1 -type f -iname "*.octet-stream*")
            shift;
        done
        cat /dev/null > resources/csv/many_samples.csv
        cat /dev/null > resources/csv/many_biotemplates.csv
        cat /dev/null > resources/csv/template_ids.csv
}

biotemplates() {
    if [ $(find $1 -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv/many_biotemplates.csv | wc -l) ]; then
        find $1 -type f -iname "*.octet-stream" > resources/csv/many_biotemplates.csv
    fi
}

if [ -z $1 ]; then
    f_print_usage
else
    while [ -n "$1" ]; do
        case "$1" in
            -d) DEL=1; shift;;
            -b) BG=1; shift;;
            -t) TYPE="$2"; shift; shift;;
            -s) SAMPLE_DIR="$2"; shift; shift;;
            -a) API_VERSION="$2"; shift; shift;;
            -p) PREFIX="$2"; shift; shift;;
            -r) RAMP_UP_PERIOD="$2"; shift; shift;;
            *) break;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_print_usage
    else
        JMX_FILE=resources/jmx/identification.jmx                  # Template jmeter
        MMETA=resources/metadata/mmeta.json                        # Шаблон метаданных для методов match и identify
        SUMINTERVAL=10                                             # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        SINGLE_SAMPLE_DIR="resources/samples"                      # Директория для теста в режиме одного сэмпла
        PHOTO_SAMPLE="photo.jpg"                                   # Используемый файл (photo) для теста в режиме одного сэмпла. Файл необходимо расположить в $SINGLE_SAMPLE_DIR
        SOUND_SAMPLE="sound.wav"                                   # Используемый файл (sound) для теста в режиме одного сэмпла. Файл необходимо расположить в $SINGLE_SAMPLE_DIR

        TASK_NAME=$1
        METHOD=$2
        THREADS=$3                                                 # Количество потоков (пользователей)
        LOOP="-1"                                                  # количество повторов (-1 бесконечно)

        REPORT=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP_UP_PERIOD}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv        # Отчет по запросам
        PERFLOG=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP_UP_PERIOD}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv      # Отчет PerfMon
        LOG=tmp/jmeter.log                                         # Лог jmeter
        
        ENDPOINT=$4
        DURATION=$5

        f_validate_input_params
        f_print_test_version

        SERVER="${ENDPOINT%%:*}"
        PORT="${ENDPOINT##*:}"

        if [ "$DEL" == 1 ]; then
            echo; echo "Запущен сценарий удаления ранее извлеченных шаблонов и списка идентификаторов"
            read -p "Продолжить ('y' / 'n или любой символ')? " USER_ANSWER
            if [ $USER_ANSWER = 'y' ]; then
                echo; read -p "Продолжить тестирование после очистки? ('y' / 'n или любой символ')? " USER_ANSWER
                if [ $USER_ANSWER = 'y' ]; then
                    echo; echo "Доступные режимы очистки:
        1 – удалить шаблоны и идентификаторы
        2 – удалить только идентификаторы"
                    while true; do
                        echo; read -p "Выберете режим очистки: " USER_ANSWER
                        if [ $USER_ANSWER = '1' ]; then
                            if [ -z $SAMPLE_DIR ]; then
                                rm_templates $SINGLE_SAMPLE_DIR
                                echo "Шаблоны были удалены"
                                break
                            else
                                rm_templates $SAMPLE_DIR $SINGLE_SAMPLE_DIR
                                echo "Шаблоны были удалены"
                                break
                            fi
                        elif [ $USER_ANSWER = '2' ]; then
                            cat /dev/null > resources/csv/template_ids.csv
                            echo "Список очищен"
                            break
                        else    
                            echo "Ошибка ввода. Пожалуйста, повторите попытку"
                            continue
                        fi
                    done
                else
                    echo; echo "Доступные режимы очистки:
        1 – удалить шаблоны и идентификаторы
        2 – удалить только идентификаторы"
                    while true; do
                        echo; read -p "Выберете режим очистки: " USER_ANSWER
                        if [ $USER_ANSWER = '1' ]; then
                            if [ -z $SAMPLE_DIR ]; then
                                rm_templates $SINGLE_SAMPLE_DIR
                                echo "Шаблоны были удалены"; exit
                            else
                                rm_templates $SAMPLE_DIR $SINGLE_SAMPLE_DIR
                                echo "Шаблоны были удалены"; exit
                            fi
                        elif [ $USER_ANSWER = '2' ]; then 
                            cat /dev/null > resources/csv/template_ids.csv
                            echo "Список очищен"; exit
                        else
                            echo "Ошибка ввода. Пожалуйста, повторите попытку"
                            continue
                        fi
                    done
                fi
            else
                echo; echo "Следует удалить ключ \"-d\" из передаваемых параметров"
                exit
            fi
        fi

        if [ "$TYPE" == "sound" ]; then
            CTYPE="audio/wav"                                      # content_type
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$SOUND_SAMPLE" > resources/csv/many_samples.csv                    # Внести один сэмпл
                biotemplates $SINGLE_SAMPLE_DIR                                                                     # Внести один вектор для методов match и identify
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv/many_samples.csv                # Обновить список сэмплов
                fi
                biotemplates $SAMPLE_DIR                                                                            # Обновить список векторов для методов match и identify
            fi
        else
            CTYPE="image/jpeg"
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$PHOTO_SAMPLE" > resources/csv/many_samples.csv                    # Внести один сэмпл
                biotemplates $SINGLE_SAMPLE_DIR                                                                     # Внести один вектор для методов match и identify
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv/many_samples.csv                # Обновить список сэмплов
                fi
                biotemplates $SAMPLE_DIR                                                                            # Обновить список векторов для методов match и identify
            fi
        fi
       
        if [ -n "$PREFIX" ]; then
            LOCATION="/$API_VERSION/$PREFIX/$METHOD"
        else
            LOCATION="/$API_VERSION/$METHOD"
        fi
        
        [[ -s "tmp/http_errors.xml" ]] && cat /dev/null > tmp/http_errors.xml                                       # Очистить лог http-запросов к БП, которые завершились с ошибкой, перед очередным запуском теста

        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP_UP_PERIOD' -Jpath='$LOCATION' -Jmethod='$METHOD' -Jcontent_type='$CTYPE' -Jmmeta='$MMETA' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -Jduration='$DURATION' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"

        if [ $(cat resources/csv/many_samples.csv | wc -l) -eq 0 ]; then
            echo "ERROR: no $CTYPE samples to test, check your sample directory or test type"
            exit
        fi

        eval $CMD
    fi
fi
