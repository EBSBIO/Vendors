#!/bin/bash

# ================================================================================
# DESC:    мастер-скрипт запуска тестов API liveness
# VERSION: 2.0.0
# ================================================================================

# include functions
source include/f_validate_input_params.sh
source include/f_checks.sh
source include/f_test_passive_liveness_sound.sh
source include/f_test_passive_liveness_photo.sh
source include/f_test_passive_liveness_video.sh
source include/f_test_active_liveness_video.sh

HEALTH_REGEX='^\{\s*"status":\s?0(,\s*"message":\s?".+")?\s*\}$'

f_err_regex() {
    local_code=$1
    local_message=$2

    echo '^\{\s*"code":\s?"'${local_code}'",\s*"message":\s?"'${local_message}'"\s*\}$'
}

f_print_usage() {
echo "Использование: $0 [OPTIONS] ENDPOINT TIMEOUT

OPTIONS:
  -t  string  тип тест-кейсов (выберите одно из значений):
                sound
                photo (по умолчанию)
                p_video (passive video)
                a_video (active video)
                photo+p_video
                p_video+a_video
    
  -m  string  мнемоника (только для active liveness):
                move (move-instructions)
                text (text-instructions)
  
  -i  string  инструкции к действию (только для мнемоники move-instructions):
                1 (TURN_RIGHT)
                2 (TURN_LEFT)
                3 (TURN_UP)
                4 (TURN_DOWN)
                5 (SMILE)
                6 (BLINK)
                7 (DISTORTION)
                8 (RAISE_EYEBROW)
                all
                    
              примеры:
                -i 1,2,3,4,6
                -i all
    
  -a  string  версия API (по умолчанию \"v1\")
  -p  string  префикс (необязательная составная часть пути)
  -v          вывод результатов тестов с признаком \"FAIL\"
  -vv         вывод результатов всех тестов
  
ENDPOINT  string  <IP/DNS>:<ПОРТ>
TIMEOUT   int     максимальное время (сек) на выполнение каждого тест-кейса
"
}

f_test_health() {
    VENDOR_URL="$BASE_URL/health"

    TEST_NAME="health 400. LDE-002006 – Неверный запрос. Bad location"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL/health
    f_check -r 400 -m "$(f_err_regex 'LDE-002006' 'Неверный запрос')"
}

if [ -z "$1" ]; then
    f_print_usage
else
    V=0
    while [ -n "$1" ]; do
        case "$1" in
            -t) TYPE="$2"; shift; shift;;
            -m) MNEMONIC="$2"; shift; shift;;
            -i) INSTRUCTIONS="$2"; shift; shift;;
            -a) API_VERSION="$2"; shift; shift;;
            -p) PREFIX="$2"; shift; shift;;            
            -v) V=1; shift;;
            -vv) V=2; shift;;
            -*) shift;;
            *)  break;;
        esac
    done

    if [ -z "$1" ]; then
        f_print_usage
    else
        ENDPOINT=$1
        TIMEOUT=$2
        
        f_validate_input_params

        if [ -n "$PREFIX" ]; then
            BASE_URL="http://${ENDPOINT}/${API_VERSION}/${PREFIX}/liveness"
        else
            BASE_URL="http://${ENDPOINT}/$API_VERSION/liveness"
        fi

        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"
        TEST_NAME="health 200"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        mkdir -p tmp
        f_check -r 200 -m ${HEALTH_REGEX}

        if [ "$FAIL" -eq 0 ]; then
            SUCCESS=0
            ERROR=0

            echo; echo "------------ Begin: f_test_health -------------"
            f_test_health

            if [ "$TYPE" == "sound" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_sound -------------"
                f_test_passive_liveness_sound $TYPE
            
            elif [ "$TYPE" == "p_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE

            elif [ "$TYPE" == "a_video" ]; then
                echo; echo; echo "------------ Begin: f_test_active_liveness_video -------------"
                f_test_active_liveness_video $TYPE $MNEMONIC $INSTRUCTIONS

            elif [ "$TYPE" == "photo+p_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_photo -------------"
                f_test_passive_liveness_photo $TYPE
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE

            elif [ "$TYPE" == "p_video+a_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE
                echo; echo; echo "------------ Begin: f_test_active_liveness_video -------------"
                f_test_active_liveness_video $TYPE $MNEMONIC $INSTRUCTIONS
                
            else
                echo; echo; echo "------------ Begin: f_test_passive_liveness_photo -------------"
                f_test_passive_liveness_photo $TYPE
            fi
            
            echo -e "\n\nSCORE: success $SUCCESS, error $ERROR"
        fi
    fi
fi
