#!/bin/bash

if [ "$#" -ne "4" ]
then
  echo Usage: "$0" TASK_NAME METHOD THREADS URL:PORT
  exit 1
fi

JPATH=/opt/apache-jmeter/bin                # Путь к ПО Jmeter
JMX_FILE=resources/jmx/verification.jmx    # Template jmeter

JREPORT=reports/${1}/${2}_${3}thr_$(date "+%Y-%m-%d-%H:%M:%S")_report.csv  # Лог
JPERFLOG=reports/${1}/${2}_${3}thr_$(date "+%Y-%m-%d-%H:%M:%S")_perflog.csv  # Отчет PerfMon
JLOG=tmp/jmeter.log			    # Лог jmeter
JOUT=tmp/jmeter_load.out                  # Output jmeter

THREADS=$3                               # Количество потоков (пользователей)
RAMP=0                                     # Период (в сек) между запуском новых тредов (пользователей)
LOOP="-1"                                  # количество повторов (-1 безконечно)

SAMPLE="$PWD/resources/photo.png"           # Используемый в тесте файл. Файл необходимо расположить в папке resources
CTYPE="image/png"                           # content_type, указать image/jpeg для модальности photo или audio/pcm для модальности sound
JTASK=$PWD/scripts/req-${2}.sh              # Скрипт проверки вендора

VENDOR_URL=http://$4/v1                     # URL


# Запуск
date "+%Y-%m-%d-%H:%M:%S" > $JOUT
CMD='screen -dmS start.jmeter sh -c "'$JPATH'/jmeter -n -t '$JMX_FILE' -Jthreads='$THREADS' -Jloop='$LOOP' -JRamp='$RAMP' -Jtask='$JTASK' -Jcontent_type='$CTYPE' -Jdata='$SAMPLE' -Jvendor='$VENDOR_URL' -Jperflog='$JPERFLOG' -j '$JLOG' -l '$JREPORT' >> '$JOUT'"'

echo "CMD: $CMD"
echo ""
eval $CMD
