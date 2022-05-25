#!/bin/bash

if [ "$#" -ne "4" ]
then
  echo Usage: "$0" TASK_NAME THREADS URL PORT
  exit 1
fi


JPATH=/opt/apache-jmeter/bin                # Путь к ПО Jmeter
JMX_FILE=resources/liveness_n.jmx            # Template jmeter
JREPORT=report/${1}/${2}_${3}thr_$(date "+%Y-%m-%d-%H:%M:%S")_log.csv  # Лог

THREADS=$2                                  # Количество потоков (пользователей)
JLOOP="-1"                                  # Количество повторов (-1 безконечно)
JRAMP=0                                     # Период (в сек) между запуском новых тредов (пользователей)

SAMPLE="resources/photo.png"               # Используемый в тесте файл. Файл необходимо расположить в папке resources
CTYPE="image/png"                          # content_type, указать image/jpeg для модальности photo или audio/pcm для модальности sound
META="resources/meta.json"                 # Metadata, json файл для теста liveness

SERVER=$3
PORT=$4

CMD=$JPATH'/jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -JRamp='$RAMP' -Jcontent_type='$CTYPE' -Jsample='$SAMPLE' -Jserver='$SERVER' -jport='$PORT' -l '$JREPORT

echo "CMD: $CMD"
echo ""
eval $CMD
