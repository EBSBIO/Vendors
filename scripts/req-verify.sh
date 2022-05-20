#!/usr/bin/env bash

if [ "$#" -ne "3" ]
then
  echo Usage: "$0" data_type data vendor
  exit 1
fi

curl --max-time 15000 -v -H "Content-Type:multipart/form-data" -F "bio_template=@$PWD/resources/bio_template;type=application/octet-stream" -F "sample=@$PWD/Resources/${2};type=${1}" --output /dev/null ${3}/pattern/verify
