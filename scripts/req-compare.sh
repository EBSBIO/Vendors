#!/usr/bin/env bash

if [ "$#" -ne "1" ]
then
  echo Usage: "$0" data_type data vendor
  exit 1
fi

curl --max-time 15000 -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "bio_template=@/home/nbp/apache-jmeter-5.0/TESTS/resources/bio_template;type=application/octet-stream" -F "bio_feature=@/home/nbp/apache-jmeter-5.0/TESTS/resources/bio_template;type=application/octet-stream"  --output /dev/null ${1}/pattern/compare
