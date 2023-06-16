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
    -t string       Type (sound|photo)
    
    TASK_NAME       Vendor name
    METHOD          extract, add, update, delete, match, identify
    THREADS         Sum threads(users)
    URL             IP
    PORT            TCP порт БП"
}

rm_templates() {
        local IFS=$'\n'
        while [ -n "$1" ]; do
            rm -f $(find $1 -type f -iname "*.octet-stream*")
            shift;
        done
        cat /dev/null > resources/csv_configs/many_samples.csv
        cat /dev/null > resources/csv_configs/many_biotemplates.csv
        cat /dev/null > resources/csv_configs/many_meta.csv
}

biotemplates() {
    if [ $(find $1 -type f -iname "*.octet-stream" | wc -l) -ne $(cat resources/csv_configs/many_biotemplates.csv | wc -l) ]; then
        find $1 -type f -iname "*.octet-stream" > resources/csv_configs/many_biotemplates.csv
    fi
}

create_metadata() {
local IFS=$'\n'
COUNT=1
if [ $(find $1 -type f -iname "*.octet-stream" | wc -l) -gt 0 ]; then
    for i in $(cat resources/csv_configs/many_biotemplates.csv); do
        META=${i}.id
        echo {\"template_id\":\""$COUNT"\"} > "$META"
        COUNT=$(( $COUNT + 1 ))
    done
fi
}

metadata() {
    if [ $(find $1 -type f -iname "*.octet-stream.id" | wc -l) -ne $(cat resources/csv_configs/many_meta.csv | wc -l) ]; then
        find $1 -type f -iname "*.octet-stream.id" > resources/csv_configs/many_meta.csv
    fi
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
            -p) PREFIX=$2; shift; shift;;
            -t) TYPE=$2; shift; shift;;
            *) break;;
        esac
    done
    if [ "$#" -ne "5" ]; then
        f_usage
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
        LOOP="-1"                                                  # количество повторов (-1 беcконечно)
        [ -z $RAMP ] && RAMP=0                                     # Длительность (в сек) для «наращивания» до полного числа выбранных потоков

        REPORT=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv        # Отчет по запросам
        PERFLOG=reports/${TASK_NAME}/${METHOD}_${THREADS}thr_${RAMP}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv      # Отчет PerfMon
        LOG=tmp/jmeter.log                                         # Лог jmeter
        
        SERVER=$4
        PORT=$5                                                    # URL

        if [ "$DEL" == 1 ]; then
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
            CTYPE="audio/wav"                                      # content_type
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$SOUND_SAMPLE" > resources/csv_configs/many_samples.csv                    # Внести один сэмпл
                biotemplates $SINGLE_SAMPLE_DIR                                                                     # Внести один вектор для методов match и identify
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.wav" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.wav" > resources/csv_configs/many_samples.csv                # Обновить список сэмплов
                fi
                biotemplates $SAMPLE_DIR                                                                            # Обновить список векторов для методов match и identify
            fi
        else
            CTYPE="image/jpeg"
            if [ -z $SAMPLE_DIR ]; then
                echo "$SINGLE_SAMPLE_DIR/$PHOTO_SAMPLE" > resources/csv_configs/many_samples.csv                    # Внести один сэмпл
                biotemplates $SINGLE_SAMPLE_DIR                                                                     # Внести один вектор для методов match и identify
            else
                if [ $(find $SAMPLE_DIR -type f -iname "*.jpg" | wc -l) -ne $(cat resources/csv_configs/many_samples.csv | wc -l) ]; then
                    find $SAMPLE_DIR -type f -iname "*.jpg" > resources/csv_configs/many_samples.csv                # Обновить список сэмплов
                fi
                biotemplates $SAMPLE_DIR                                                                            # Обновить список векторов для методов match и identify
            fi
        fi
        
        if [ -z $SAMPLE_DIR ]; then
            create_metadata $SINGLE_SAMPLE_DIR                                                                      # Создать файл с метаданными для методов add и update для теста в режиме одного сэмпла
        else
            create_metadata $SAMPLE_DIR                                                                             # Создать файлы с метаданными для методов add и update
        fi

        if [ -z $SAMPLE_DIR ]; then
            metadata $SINGLE_SAMPLE_DIR
        else
            metadata $SAMPLE_DIR                                                                                    # Обновить список файлов с метаданными для методов add и update
        fi

        if [ -n "$PREFIX" ]; then
            LOCATION="/v1/$PREFIX/$METHOD"
        else
            LOCATION="/v1/$METHOD"
        fi
        
        cat /dev/null > tmp/http_errors.log                        # Очистить лог http-запросов к БП, которые завершились с ошибкой, перед очередным запуском теста

        CMD='jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jpath='$LOCATION' -Jmethod='$METHOD' -Jcontent_type='$CTYPE' -Jmmeta='$MMETA' -Jsummariser.interval='$SUMINTERVAL' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$PERFLOG' -j '$LOG' -l '$REPORT

        if [ "$BG" == 1 ]; then
            CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
        fi
        echo -e "\nCMD: $CMD\n"

        if [ $(cat resources/csv_configs/many_samples.csv | wc -l) -eq 0 ]; then
            echo "ERROR: no $CTYPE samples to test, check your sample directory or test type"
            exit
        fi

        eval $CMD
    fi
fi
