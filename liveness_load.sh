#!/bin/bash

if [ "$#" -ne "4" ]
then
  echo Usage: "$0" TASK_NAME THREADS URL PORT
  exit 1
fi


JPATH=/opt/apache-jmeter/bin                # Путь к ПО Jmeter
JMX_FILE=resources/liveness_n.jmx            # Template jmeter
JREPORT=report/${1}/liveness_${2}thr_$(date "+%Y-%m-%d-%H:%M:%S")_log.csv  # Лог

THREADS=$2                                  # Количество потоков (пользователей)
LOOP="-1"                                  # Количество повторов (-1 безконечно)
RAMP=0                                     # Период (в сек) между запуском новых тредов (пользователей)

SAMPLE="resources/photo_velmozhin.jpg"               # Используемый в тесте файл. Файл необходимо расположить в папке resources
CTYPE="image/jpeg"                          # content_type, указать image/jpeg для модальности photo или audio/pcm для модальности sound
META="resources/meta.json"                 # Metadata, json файл для теста liveness

SERVER=$3				# DNS/IP имя сервера с развернутым БП
PORT=$4					# Порт БП

CMD=$JPATH'/jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -JRamp='$RAMP' -Jcontent_type='$CTYPE' -Jsample='$SAMPLE' -Jmeta='$META' -Jserver='$SERVER' -Jport='$PORT' -l '$JREPORT

echo "CMD: $CMD"
echo ""
eval $CMD
