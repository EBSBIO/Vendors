#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
# Ver: 0.1               #
#                        #
##########################

# include functions
source include/f_checks.sh

f_extract () {
    mkdir -p reports/$TNAME/
    rm -rf reports/$TNAME/*

    VENDOR_URL="$BASE_URL/extract"

    for FILE in $DIR/*; do
        #echo $FILE
        FNAME=$(basename $FILE)
        BODY=reports/$TNAME/biotemplate-$FNAME
        cp $FILE reports/$TNAME/

        TEST_NAME="extract $FILE"
        REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @'$FILE' --output '$BODY' '$VENDOR_URL
        f_check -r 200 -b -s
    done

    cd reports/$TNAME && tar -cf ../$TNAME.tar *
}


f_print_usage() {
echo "Usage: $0 [OPTIONS] NAME DIR URL

OPTIONS:
    -r  string      Version api
    -p  string      Prefix
    -v              Verbose FAIL checks
    -vv             Verbose All checks

NAME    test name
DIR     path to file directory
URL     <ip>:<port>
"
}


if [ -z "$1" ]; then
    f_print_usage
else
    V=0
    while [ -n "$1" ]; do
        case "$1" in
            -r) R="$2"; shift; shift;;
            -p) P=$2; shift; shift;;
            -v) V=1; shift;;
            -vv) V=2; shift;;
            -*) shift;;
            *)  break;;
        esac
    done
    if [ -z "$1" ]; then
        f_print_usage
    else
        TNAME=$1
        DIR=$2
        URL=$3
    
        [ -z $R ] && R="v1" # version
        
        if [ -n "$P" ]; then
            BASE_URL="http://$URL/$R/$P/pattern"
        else
            BASE_URL="http://$URL/$R/pattern"
        fi
        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"

        TEST_NAME="Healt.200"
        REQUEST='curl -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        mkdir -p tmp
        f_check -r 200 -m "\"?[Ss]tatus\"?:\s?0"
    
        if [ "$FAIL" -eq 0 ]; then
           f_extract 
        fi

    fi
fi
