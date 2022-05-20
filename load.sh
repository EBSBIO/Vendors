#!/bin/bash

if [ "$#" -ne "4" ]
then
  echo Usage: "$0" TASK_NAME METHOD THREADS URL:PORT
  exit 1
fi

VENDOR_URL=http://$4/v1                     # URL
JPATH=/opt/apache-jmeter/bin                # Путь к ПО Jmeter
JMX_FILE=$PWD/resources/load_test.jmx       # Template jmeter
JTASK=$PWD/scripts/req-${2}.sh              # Скрипт проверки вендора
JREPORT=$PWD/report/${1}/${2}_${3}thr_$(date "+%Y-%m-%d-%H:%M:%S")_log.csv  # Лог
JRAMP=0                                     # Период (в сек) между запуском новых тредов (пользователей)
JLOOP="-1"                                  # количество повторов (-1 безконечно)

CMD=$JPATH'/jmeter -n -t '$JMX_FILE' -Jthreads='${3}' -Jloop='$JLOOP' -JRamp='$JRAMP' -Jtask='$JTASK' -Jcontent_type=image/png -Jdata='$PWD'/resources/photo.png -Jvendor='$VENDOR_URL' -l '$JREPORT

# старт задачи JMeter, логи в файл jmeter_load.out
date "+%Y-%m-%d-%H:%M:%S" >> jmeter_load.out
#screen -dmS start.jmeter sh -c "$JPATH/jmeter -n -t $JMX_FILE -Jthreads=${3} -Jloop=-1 -Jtask=$JTASK -Jcontent_type=image/png -Jdata=photo.png -Jvendor=$JVENDOR -l $JREPORT >> jmeter_load.out"
#echo "JMeter ${1}-task has started."

echo "CMD: $CMD"
echo ""
eval $CMD
