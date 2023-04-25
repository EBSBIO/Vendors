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
    -s              Absolute path to the directory where samples for testing
    -r num          Ramp-up period (sec, default 0)
    -p string       Prefix
    -v string       Version
    -t string       Type (sound|photo)
    
    TASK_NAME       Vendor name
    METHOD          extract, verify, compare
    THREADS         Sum threads(users)
    URL             IP
    PORT            TCP порт БП"
}

rm_templates() {
        local IFS=$'\n'
        while [ -n "$1" ]; do
            rm -f $(find $1 -type f -iname "*.octet-stream*" -o -iname "*.json")
            shift;
        done
        cat /dev/null > resources/csv_configs/many_samples.csv
        cat /dev/null > resources/csv_configs/many_biotemplates.csv
}

if [ -z $1 ]; then
    f_usage
else
    while [ -n "$1" ]; do
        case "$1" in
            -d) DEL=1; shift;;
            -b) BG=1; shift;;
            -s) SAMPLE_DIR=$2; shift; shift;;
            -r) RAMP=$2; shift; shift;;
            -v) VERSION=$2; shift; shift;;
            -p) PREFIX=$2; shift; shift;;
            -t) TYPE=$2; shift; shift;;
            *) break;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_usage
    else        
        JMX_FILE=resources/jmx/verification.jmx                  # Template jmeter
        SUMINTERVAL=10                                           # Интервал (в сек) обновления summariser (таблицы результатов в логе)
        SINGLE_SAMPLE_DIR="resources/samples"                    # Директория для теста в режиме одного сэмпла
        PHOTO_SAMPLE="photo.jpg"                                 # Используемый файл (photo) для теста в режиме одного сэмпла. Файл необходимо расположить в $SINGLE_SAMPLE_DIR
        SOUND_SAMPLE="sound.wav"                                 # Используемый файл (sound) для теста в режиме одного сэмпла. Файл необходимо расположить в $SINGLE_SAMPLE_DIR

        TASK_NAME=$1
        METHOD=$2
        THREADS=$3                                               # Количество потоков (пользователей)
        LOOP="-1"                                                # количество повторов (-1 беcконечно)
        [ -z $RAMP ] && RAMP=0                                   # Длительность (в сек) для «наращивания» до полного числа выбранных потоков
        [ -z $VERSION ] && VERSION="v1"
        
        REPORT=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv        # Отчет по запросам
        PERFLOG=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv      # Отчет PerfMon
        LOG=tmp/jmeter.log                                       # Лог jmeter
        
        SERVER=$4
        PORT=$5                                                  # URL
        
        if [ "$DEL" == 1 ]; then                                                                                    # Удаление ранее извлеченных шаблонов *.octet-stream
            echo
            echo "The previous templates will be deleted"
            read -p "Are you sure you want to continue ('y' / 'n or any value')? " USER_ANSWER
            if [ $USER_ANSWER = 'y' ]; then
                echo
                read -p "Do you want to continue testing after cleaning? ('y' / 'n or any value')? " USER_ANSWER
                if [ $USER_ANSWER = 'y' ]; then
                    if [ -z $SAMPLE_DIR ]; then
                        rm_templates $SINGLE_SAMPLE_DIR
                        echo "Templates have been removed"
                    else
                        rm_templates $SAMPLE_DIR $SINGLE_SAMPLE_DIR
                        echo "Templates have been removed"
                    fi
                else
                    if [ -z $SAMPLE_DIR ]; then
                        rm_templates $SINGLE_SAMPLE_DIR
                        echo "Templates have been removed. Exit test"
                        exit
                    else
                        rm_templates $SAMPLE_DIR $SINGLE_SAMPLE_DIR
                        echo "Templates have been removed. Exit test"
                        exit
                    fi
                fi
            else
                echo; echo "Remove the key \"-d\" from the script parameters"
                exit
            fi
        fi

        if [ "$TYPE" == "sound" ]; then
            CTYPE="audio/wav"                                    # content_type
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$SOUND_SAMPLE" > resources/csv_configs/many_samples.csv                                   # Внести один сэмпл
                if [ $(find $SINGLE_SAMPLE_DIR -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
                    find $SINGLE_SAMPLE_DIR -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv          # Внести один вектор
                fi
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
                if [ $(find $SAMPLE_DIR -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv                 # Обновить список векторов для методов compare и verify
                fi
            fi
        else
            CTYPE="image/jpeg"
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$PHOTO_SAMPLE" > resources/csv_configs/many_samples.csv                                   # Внести один сэмпл
                if [ $(find $SINGLE_SAMPLE_DIR -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
                    find $SINGLE_SAMPLE_DIR -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv          # Внести один вектор
                fi
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                               # Обновить список сэмплов
                fi
                if [ $(find $SAMPLE_DIR -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv                 # Обновить список векторов для методов compare и verify
                fi
            fi
        fi

        if [ -n "$PREFIX" ]; then
            LOCATION="/$VERSION/$PREFIX/pattern/$METHOD"
        else
            LOCATION="/$VERSION/pattern/$METHOD"
        fi

        cat /dev/null > tmp/http_errors.log                      # Очистить лог http-запросов к БП, которые завершились с ошибкой, перед очередным запуском теста

        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jmethod='$METHOD' -Jcontent_type='$CTYPE' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"
        eval $CMD
    fi
fi