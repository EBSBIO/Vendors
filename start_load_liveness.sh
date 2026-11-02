#!/bin/bash

# ================================================================================
# DESC:    скрипт запуска нагрузочных тестов API liveness посредством jmeter
# VERSION: 1.1.0
# ================================================================================

# include functions
source include/f_validate_input_params.sh
source include/f_print_test_version.sh

CURRENT_FILE="${BASH_SOURCE[0]}"

f_print_usage() {
echo Использование: "$0 [OPTIONS] TASK_NAME THREADS ENDPOINT

OPTIONS:
  -b          запуск в фоновом режиме (screen)
  -t  string  тип тест-кейсов (выберите одно из значений): sound, photo (по умолчанию), video
  -s  string  абсолютный путь к директории, в которой образцы для тестирования (для типа video опция обязательна)
  -a  string  версия API (по умолчанию \"v1\")
  -p  string  префикс (необязательная составная часть пути)
  -r  int     период ramp-up, сек (по умолчанию 0)
  
TASK_NAME  string  наименование вендора
THREADS    string  количество потоков нагрузки
ENDPOINT   string  <IP/DNS>:<ПОРТ>
"
}

if [ -z $1 ]; then
    f_print_usage
else
    while [ -n "$1" ]; do
        case "$1" in
            -b) BG=1; shift;;
            -t) TYPE="$2"; shift; shift;;
            -s) SAMPLE_DIR="$2"; shift; shift;;
            -a) API_VERSION="$2"; shift; shift;;
            -p) PREFIX="$2"; shift; shift;;
            -r) RAMP="$2"; shift; shift;;
            *) break ;;
        esac
    done
    if [ "$#" -ne "3" ]; then
        f_print_usage
    else
        JMX_FILE=resources/jmx/liveness.jmx                   # Template jmeter
        SUMINTERVAL=10                                        # Интервал (в сек) обновления summariser (таблицы результатов в логе)  
        SOUND_SAMPLE="resources/samples/sound_10s.wav"        # Используемый файл (sound) для теста в режиме одного сэмпла. Файл необходимо расположить в папке resources
        PHOTO_SAMPLE="resources/samples/photo_shumskiy.jpg"   # Используемый файл (photo) для теста в режиме одного сэмпла. Файл необходимо расположить в папке resources
        
        TASK_NAME=$1
        THREADS=$2                              # Количество потоков (пользователей)
        LOOP="-1"                               # Количество повторов (-1 беcконечно)

        REPORT=reports/${TASK_NAME}/liveness_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv    # Отчет по запросам
        PERFLOG=reports/${TASK_NAME}/liveness_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                      # Лог jmeter

        ENDPOINT=$3                             # DNS/IP имя сервера с развернутым БП
        
        f_validate_input_params
        f_print_test_version

        SERVER="$TMP_SERVER"
        PORT="$TMP_PORT"
        
        if [[ "$TYPE" == "sound" ]]; then
            CTYPE="audio/wav"                                                                                                      # content_type
            echo "resources/metadata/meta_lv_s_p_10s.json" > resources/csv_configs/metadata.csv                                    # Metadata, json файл для теста liveness
            if [ -z $SAMPLE_DIR ]; then
                echo "$SOUND_SAMPLE" > resources/csv_configs/many_samples.csv                                                      # Внести один сэмпл
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
            fi
        elif [[ "$TYPE" == "photo" ]]; then
            CTYPE="image/jpeg"                                                                                                     # content_type
            echo "resources/metadata/meta.json" > resources/csv_configs/metadata.csv                                               # Metadata, json файл для теста liveness
            if [ -z $SAMPLE_DIR ]; then
                echo "$PHOTO_SAMPLE" > resources/csv_configs/many_samples.csv                                                      # Внести один сэмпл
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
            fi
        elif [[ "$TYPE" == "video" ]]; then
            CTYPE="video/mov"                                                                                                      # content_type
            if [ -z $SAMPLE_DIR ]; then
                echo; echo "You need to run the script with the \"-s\" option, specifying the path to the test samples with metadata"
                exit
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*json*" | wc -l) -ne $(cat resources/csv_configs/metadata.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*json*" | sort > resources/csv_configs/metadata.csv                           # Обновить список сэмплов
                fi

                if [ $(find $SAMPLE_DIR -type f -iname "*mov*" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*mov*" | sort > resources/csv_configs/many_samples.csv                        # Обновить список сэмплов
                fi
            fi
        else
            f_print_usage; exit
        fi

        if [ -n "$PREFIX" ]; then
            LOCATION="/$API_VERSION/$PREFIX/liveness/detect"
        else
            LOCATION="/$API_VERSION/liveness/detect"
        fi
        
        [[ -s "tmp/http_errors.xml" ]] && cat /dev/null > tmp/http_errors.xml                                       # Очистить лог http-запросов к БП, которые завершились с ошибкой, перед очередным запуском теста

        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jcontent_type='$CTYPE' -Jmeta='$META' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT
        
        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"

        if [ $(cat resources/csv_configs/many_samples.csv | wc -l) -eq 0 ]; then
            echo; echo "ERROR: no $CTYPE samples to test, check your sample directory or test type"
            exit
        fi

        eval $CMD
    fi
fi
