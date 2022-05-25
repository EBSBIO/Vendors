#!/usr/bin/env bash

if [ "$#" -ne "3" ]
then
  echo Usage: "$0" data_type data vendor
  exit 1
fi

#curl -v -H "Content-Type:${1}" -H "Expect:" --data-binary @${2} --output tmp/responce_body ${3}/pattern/extract
#    
#META="resources/meta.json"
#SAMPLE_JPG="resources/photo_velmozhin.jpg"
#BODY="tmp/responce_body"
#
#curl -v -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY'  '${3}/liveness/detect
