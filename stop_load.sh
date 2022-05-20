#!/bin/bash

for s in $(screen -ls|grep -o start.*)
do
screen -X -S $s quit
done

echo "Done. JMeter task is stopped."
