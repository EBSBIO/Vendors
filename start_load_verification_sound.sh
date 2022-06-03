#!/bin/bash

##########################
#                        #
# Author: kflirik        #
#                        #
##########################

f_usage(){
echo Usage: "$0 [OPTIONS] TASK_NAME THREADS RAMP URL PORT
    
    OPTIONS:
    -b              Start in background (screen)
    -r  num         Ramp-up period (sec, default 0)
    
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
            -b) BG=1
                shift
            ;;
            -r) RAMP=$2
                shift; shift
            ;;
            *) break
            ;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_usage
    else
        JMX_FILE=resources/jmx/verification.jmx     # Template jmeter
        SUMINTERVAL=10                              # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        
        METHOD=$2
        THREADS=$3                                  # Количество потоков (пользователей)
        LOOP="-1"                                   # количество повторов (-1 безконечно)
        [ -z $RAMP ] && RAMP=0                      # Длительность (в сек) для «наращивания» до полного числа выбранных потоков.

        REPORT=reports/${1}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv  # Отчет по запросам
        PERFLOG=reports/${1}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                          # Лог jmeter
        
        SAMPLE="resources/samples/sound.wav"   # Используемый в тесте файл. Файл необходимо расположить в папке resources
        CTYPE="audio/pcm"                      # content_type, указать image/jpeg для модальности photo или audio/pcm для модальности sound
        BIOTEMPLATE="tmp/biotemplate"
        
        SERVER=$4
        PORT=$5                  # URL
        
        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -JRamp='$RAMP' -Jmethod='$METHOD' -Jsample='$SAMPLE' -Jcontent_type='$CTYPE' -Jbiotemplate='$BIOTEMPLATE' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        eval $CMD
    fi
fi      
