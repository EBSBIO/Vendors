#!/bin/bash

##########################
#                        #
# Author: kflirik        #
#                        #
##########################

f_usage(){
echo Usage: "$0 [OPTIONS] TASK_NAME METHOD THREADS URL PORT
    
    OPTIONS:
    -b              Start in background (screen)
    -r num          Ramp-up period (sec, default 0)
    -p string       Prefix
    -t string       Type (sound|photo)
    
    TASK_NAME       Vendor name
    METHOD          extract, verify, compare
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
            *) break;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_usage
    else
        JMX_FILE=resources/jmx/identification.jmx     # Template jmeter
        SUMINTERVAL=10                              # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        
        METHOD=$2
        THREADS=$3                                  # Количество потоков (пользователей)
        LOOP="3"                                   # количество повторов (-1 безконечно)
        [ -z $RAMP ] && RAMP=0                      # Длительность (в сек) для «наращивания» до полного числа выбранных потоков.

        REPORT=reports/${1}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv  # Отчет по запросам
        PERFLOG=reports/${1}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                          # Лог jmeter

        BIOTEMPLATE="tmp/biotemplate"
        META=\''metadata={"template_id":"12345"};type=application/json'\'
        MMETA=resources/metadata/mmeta.json
        UUID="4896c91b-9e61-3129-87b6-8aa299028058"
        TEMPLATE_ID="12345"
        
        SERVER=$4
        PORT=$5                  # URL
        
        if [ "$TYPE" == "sound" ]; then
            SAMPLE="resources/samples/sound.wav"   # Используемый в тесте файл.
            CTYPE="audio/pcm"                      # content_type
        else
            SAMPLE="resources/samples/photo.png"
            CTYPE="image/png"
        fi
        
        if [ -n $PREFIX ]; then
            LOCATION="/v1/$PREFIX/pattern/$METHOD"
        else
            LOCATION="/v1/pattern/$METHOD"
        fi
        
        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jmethod='$METHOD' -Jsample='$SAMPLE' -Jphoto='$SAMPLE' -Jcontent_type='$CTYPE' -Jbiotemplate='$BIOTEMPLATE' -Jmmeta='$MMETA' -JUUID='$UUID' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        eval $CMD
    fi
fi      
