#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
# Version 1.24.0         #
#                        #
##########################

f_usage(){
echo Usage: "$0 [OPTIONS] TASK_NAME THREADS URL PORT
    
    OPTIONS:
    -b              Start in background (screen)
    
    -s              Absolute path to the directory where samples for testing
                    For video type it's a must-have option

    -r num          Ramp-up period (sec, default 0)
    -p string       Prefix
    -t              Type (sound|photo|video, default photo)

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
            -s) SAMPLE_DIR=$2; shift; shift;;
            -r) RAMP=$2; shift; shift;;
            -p) PREFIX=$2; shift; shift;;
            -t) TYPE=$2; shift; shift;;
            *) break ;;
        esac
    done
    if [ "$#" -ne "4" ]; then
        f_usage
    else
        JMX_FILE=resources/jmx/liveness.jmx                   # Template jmeter
        SUMINTERVAL=10                                        # Интервал (в сек) обновления summariser (таблицы результатов в логе)  
        SOUND_SAMPLE="resources/samples/sound_10s.wav"        # Используемый файл (sound) для теста в режиме одного сэмпла. Файл необходимо расположить в папке resources
        PHOTO_SAMPLE="resources/samples/photo_shumskiy.jpg"   # Используемый файл (photo) для теста в режиме одного сэмпла. Файл необходимо расположить в папке resources
        
        [ -z $TYPE ] && TYPE="photo"
        echo "Type – $TYPE"
        
        if [[ "$TYPE" == "sound" ]]; then
            CTYPE="audio/wav"                                   # content_type
            META="resources/metadata/meta_lv_s_p_10s.json"      # Metadata, json файл для теста liveness
            if [ -z $SAMPLE_DIR ]; then
                echo "$SOUND_SAMPLE" > resources/csv_configs/many_samples.csv                                                      # Внести один сэмпл
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
            fi
        elif [[ "$TYPE" == "photo" ]]; then
            CTYPE="image/jpeg"                                  # content_type
            META="resources/metadata/meta.json"                 # Metadata, json файл для теста liveness
            if [ -z $SAMPLE_DIR ]; then
                echo "$PHOTO_SAMPLE" > resources/csv_configs/many_samples.csv                                                      # Внести один сэмпл
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
            fi
        elif [[ "$TYPE" == "video" ]]; then
            CTYPE="video/mov"                                   # content_type
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
            f_usage; exit
        fi

        THREADS=$2                              # Количество потоков (пользователей)
        LOOP="-1"                               # Количество повторов (-1 беcконечно)
        [ -z $RAMP ] && RAMP=0                  # Длительность (в сек) для «наращивания» до полного числа выбранных потоков

        REPORT=reports/${1}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv    # Отчет по запросам
        PERFLOG=reports/${1}/liveness_${2}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
        LOG=tmp/jmeter.log                      # Лог jmeter

        SERVER=$3                               # DNS/IP имя сервера с развернутым БП
        PORT=$4                                 # Порт БП

        if [ -n $PREFIX ]; then
            LOCATION="/v1/$PREFIX/liveness/detect"
        else
            LOCATION="/v1/liveness/detect"
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
