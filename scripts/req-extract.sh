#!/usr/bin/env bash

if [ "$#" -ne "3" ]
then
  echo Usage: "$0" data_type data vendor
  exit 1
fi

curl -v -H "Content-Type:${1}" -H "Expect:" --data-binary @${2} --output tmp/responce_body ${3}/pattern/extract
#echo 'curl -v -H "Content-Type:'${1}'" -H "Expect:" --data-binary @'$PWD'/resources/'${2}' --output template '${3}'/pattern/extract'
