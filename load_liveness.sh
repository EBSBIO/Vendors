#!/bin/bash
##########################
# Author: kflirik        #
#                        #
##########################

if [ -n $1 ]; then
  while [ -n "$1" ]; do
    case "$1" in
      -d) D=1
	 echo "Run in screen"
	 shift
      ;;
      *)  break
      ;;
    esac
  done
  if [ "$#" -ne "5" ]; then
    echo Usage: "$0 [OPTIONS] TASK_NAME THREADS RAMP URL PORT

      OPTIONS:
	-d	Start in screen

      TASK_NAME	Vendor name
      THREADS		Количество потоков (пользователей)
      RAMP		Время (в сек) на плавный запуск потоков. От 1 до THREADS
      URLi		IP
      PORT		Не поверишь ... TCP порт на котором слушает БП
    "
    exit 1
  fi
fi


JPATH=/opt/apache-jmeter/bin             # Путь к ПО Jmeter
JMX_FILE=resources/jmx/liveness.jmx        # Template jmeter

JREPORT=reports/${1}/liveness_${2}thr_${3}r_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv    # Отчет по запросам
JPERFLOG=reports/${1}/liveness_${2}thr_${3}r_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
JLOG=tmp/jmeter.log			 # Лог jmeter

THREADS=$2                               # Количество потоков (пользователей)
LOOP="-1"                                # Количество повторов (-1 безконечно)
RAMP=$3                                  # Период (в сек) между запуском новых тредов (пользователей)

SAMPLE="resources/photo_velmozhin.jpg"   # Используемый в тесте файл. Файл необходимо расположить в папке resources
CTYPE="image/jpeg"                       # content_type, указать image/jpeg для модальности photo или audio/pcm для модальности sound
META="resources/meta.json"               # Metadata, json файл для теста liveness

SERVER=$4				 # DNS/IP имя сервера с развернутым БП
PORT=$5					 # Порт БП

# Запуск
CMD=$JPATH'/jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -Jramp='$RAMP' -Jcontent_type='$CTYPE' -Jsample='$SAMPLE' -Jmeta='$META' -Jserver='$SERVER' -Jport='$PORT' -Jperflog='$JPERFLOG' -j '$JLOG' -l '$JREPORT' -Jsummariser.interval=1'

if [ "$D" == 1 ]; then
	CMD='screen -dmS start.jmeter sh -c "'$CMD'"'
fi

echo ""
echo "CMD: $CMD"
echo ""
eval $CMD
