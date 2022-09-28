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
    if [ "$#" -ne "4" ]; then
        f_usage
    else
        JMX_FILE=resources/jmx/liveness.jmx   # Template jmeter
        SUMINTERVAL=10                          # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        
        [ -z $TYPE ] && TYPE="photo"
        echo $TYPE
        if [ "$TYPE" == "photo" ]; then
            SAMPLE="resources/samples/photo_shumskiy.jpg"   # Используемый в тесте файл. Файл необходимо расположить в папке resources
            CTYPE="image/jpeg"                              # content_type, указать image/jpeg для модальности photo или audio/wav для модальности sound
            META="resources/metadata/meta.json"             # Metadata, json файл для теста liveness
        elif [ "$TYPE" == "sound" ]; then
            SAMPLE="resources/samples/sound.wav"
            CTYPE="audio/wav"                               # content_type, указать для модальности sound audio/wav
            META="resources/metadata/meta_lv_sound_passive.json"       # Metadata, json файл для теста liveness
        else
            f_usage; exit
        fi

        
        THREADS=$2                              # Количество потоков (пользователей)
        LOOP="-1"                               # Количество повторов (-1 безконечно)
        [ -z $RAMP ] && RAMP=0                  # Длительность (в сек) для «наращивания» до полного числа выбранных потоков.

        REPORT=reports/${1}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv    # Отчет по запросам
        PERFLOG=reports/${1}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                     # Лог jmeter

        SERVER=$3                               # DNS/IP имя сервера с развернутым БП
        PORT=$4                                 # Порт БП

        if [ -n $PREFIX ]; then
            LOCATION="/v1/$PREFIX/liveness/detect"
        else
            LOCATION="/v1/liveness/detect"
        fi
        
        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jcontent_type='$CTYPE' -Jsample='$SAMPLE' -Jmeta='$META' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT
        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        $CMD
    fi
fi



