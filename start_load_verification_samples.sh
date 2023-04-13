#!/bin/bash

##########################
#                        #
# Author: kflirik        #
#                        #
##########################

f_usage() {
echo Usage: "$0 [OPTIONS] TASK_NAME METHOD THREADS URL PORT
    
    OPTIONS:
    -d              Delete previously extracted templates
    -b              Start in background (screen)
    -r num          Ramp-up period (sec, default 0)
    -p string       Prefix
    -v string       Version
    -t string       Type (sound|photo)
    
    SAMPLE_DIR      Absolute path to the directory where samples for testing
    TASK_NAME       Vendor name
    METHOD          extract, verify, compare
    THREADS         Sum threads(users)
    URL             IP
    PORT            TCP порт БП"
}

rm_templates() {
        local IFS=$'\n'
        rm -f $(find $1 -type f -iname "*.octet-stream")
}

if [ -z $1 ]; then
    f_usage
else
    while [ -n "$1" ]; do
        case "$1" in
            -d) DEL=1; shift;;
            -b) BG=1; shift;;
            -r) RAMP=$2; shift; shift;;
            -v) VERSION=$2; shift; shift;;
            -p) PREFIX=$2; shift; shift;;
            -t) TYPE=$2; shift; shift;;
            *) break;;
        esac
    done
    if [ "$#" -ne "6" ]; then
        f_usage
    else        
        JMX_FILE=resources/jmx/verification_many_samples.jmx     # Template jmeter
        SUMINTERVAL=10                                           # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        
        SAMPLE_DIR=$1
        TASK_NAME=$2
        METHOD=$3
        THREADS=$4                                               # Количество потоков (пользователей)
        LOOP="-1"                                                # количество повторов (-1 беcконечно)
        [ -z $RAMP ] && RAMP=0                                   # Длительность (в сек) для «наращивания» до полного числа выбранных потоков
        [ -z $VERSION ] && VERSION="v1"
        
        REPORT=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv        # Отчет по запросам
        PERFLOG=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv      # Отчет PerfMon
        LOG=tmp/jmeter.log                                       # Лог jmeter
        
        SERVER=$5
        PORT=$6                                                  # URL
        
        if [ "$DEL" == 1 ]; then
            echo
            echo "The previous templates will be deleted"
            read -p "Are you sure you want to continue ('y' / 'n or any value')? " answer
            if [ $answer = 'y' ]; then
                rm_templates $SAMPLE_DIR                         # Выполнить удаление ранее извлеченных шаблонов *.octet-stream
                echo "Templates have been removed"
            else
                echo
                echo "Remove the key \"-d\" from the script parameters"
                exit
            fi
        fi

        if [ "$TYPE" == "sound" ]; then
            #SAMPLE="resources/samples/sound.wav"                 # Используемый в тесте файл
            CTYPE="audio/pcm"                                    # content_type
            if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                    # Обновить список сэмплов
            fi
        else
            CTYPE="image/jpeg"
            if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                    # Обновить список сэмплов
            fi
        fi
        
        if [ $(find $SAMPLE_DIR -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
                find $SAMPLE_DIR -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv      # Обновить список векторов для методов compare и verify
        fi

        if [ -n $PREFIX ]; then
            LOCATION="/$VERSION/$PREFIX/pattern/$METHOD"
        else
            LOCATION="/$VERSION/pattern/$METHOD"
        fi

        cat /dev/null > tmp/http_errors.log                      # Очистить лог http-запросов к БП, которые завершились с ошибкой

        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jmethod='$METHOD' -Jcontent_type='$CTYPE' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        eval $CMD
    fi
fi
