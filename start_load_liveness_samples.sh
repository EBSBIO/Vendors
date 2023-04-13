#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
# Version 1.24.0         #
#                        #
##########################

f_usage(){
echo Usage: "$0 [OPTIONS] TASK_NAME THREADS RAMP URL PORT
    
    OPTIONS:
    -b              Start in background (screen)
    -r  num         Ramp-up period (sec, default 0)
    -p string       Prefix
    -t              Type (photo|sound, default photo)
    
    SAMPLE_DIR      Absolute path to the directory where samples for testing
    TASK_NAME       Vendor name
    THREADS         Sum threads(users)
    URL             IP
    PORT            TCP порт БП"
}

if [ -z $1 ]; then
    f_usage
else
    while [ -n "$1" ]; do
        case "$1" in
            -b) BG=1; shift;;
            -r) RAMP=$2; shift; shift;;
            -p) PREFIX=$2; shift; shift;;
            -t) TYPE=$2; shift; shift;;
            *) break ;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_usage
    else
        JMX_FILE=resources/jmx/liveness_many_samples.jmx    # Template jmeter
        SUMINTERVAL=10                                      # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        SAMPLE_DIR=$1

        [ -z $TYPE ] && TYPE="photo"
        echo $TYPE
        if [ "$TYPE" == "photo" ]; then
            CTYPE="image/jpeg"                              # content_type, указать image/jpeg для модальности photo или audio/wav для модальности sound
            META="resources/metadata/meta.json"             # Metadata, json файл для теста liveness
            if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
            fi
        elif [ "$TYPE" == "sound" ]; then
            CTYPE="audio/wav"                               # content_type, указать для модальности sound audio/wav
            META="resources/metadata/meta_lv_s_p_10s.json"  # Metadata, json файл для теста liveness
            if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
            fi
        else
            f_usage; exit
        fi
        
        THREADS=$3                              # Количество потоков (пользователей)
        LOOP="-1"                               # Количество повторов (-1 беcконечно)
        [ -z $RAMP ] && RAMP=0                  # Длительность (в сек) для «наращивания» до полного числа выбранных потоков.

        REPORT=reports/${2}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv    # Отчет по запросам
        PERFLOG=reports/${2}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                     # Лог jmeter

        SERVER=$4                               # DNS/IP имя сервера с развернутым БП
        PORT=$5                                 # Порт БП

        if [ -n $PREFIX ]; then
            LOCATION="/v1/$PREFIX/liveness/detect"
        else
            LOCATION="/v1/liveness/detect"
        fi
        
        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jcontent_type='$CTYPE' -Jmeta='$META' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT
        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        eval $CMD
    fi
fi



