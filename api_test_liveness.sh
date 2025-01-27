#!/bin/bash

# include functions
source include/f_checks.sh
source include/f_test_passive_liveness_sound.sh
source include/f_test_passive_liveness_photo.sh
source include/f_test_passive_liveness_video.sh
source include/f_test_active_liveness_video.sh

HEALTH_REGEX='\{\s*"status":\s?0(,\s*"message":.*)?\s*\}'
SOUND_SCORE_REGEX='\{\s*"passed":\s?(false|true),\s*"score":\s?((0\.0)|(0\.[0-9]*[1-9]+)|(1\.0))(,\s*"results":\s?\[\s*\{\s*"type":\s?"audio-type",\s*"passed":\s?(false|true)\s*\}\s*\])?\s*\}'
PHOTO_SCORE_REGEX='\{\s*"passed":\s?(false|true),\s*"score":\s?((0\.0)|(0\.[0-9]*[1-9]+)|(1\.0))(,\s*"results":\s?\[\s*\{\s*"type":\s?"photo-type",\s*"passed":\s?(false|true)\s*\}\s*\])?\s*\}'

f_print_usage() {
echo "Usage: $0 [OPTIONS] URL [TIMEOUT:-1]

OPTIONS:
    -t  string      Type (choose one of the values):
                        sound
                        photo (default)
                        p_video (passive video)
                        a_video (active video)
                        photo+p_video
                        p_video+a_video
    
    -m  string      Mnemonic (only for active liveness):
                        move (move-instructions)
                        text (text-instructions)

    -a  string      Actions types (only for move-instructions mnemonic):
                        1 (TURN_RIGHT)
                        2 (TURN_LEFT)
                        3 (TURN_UP)
                        4 (TURN_DOWN)
                        5 (SMILE)
                        6 (BLINK)
                        7 (DISTORTION)
                        8 (RAISE_EYEBROW)
                        all
                    
                    For example:
                        -a 1,2,3,4,6
                        -a all
    
    -r  string      Release/Version (from method URL)
    -p  string      Prefix
    -v              Verbose FAIL checks
    -vv             Verbose All checks

URL                 <ip>:<port>
TIMEOUT             <seconds> – maximum time in seconds that you allow the whole operation to take
"
}


f_test_health() {
    VENDOR_URL="$BASE_URL/health"

    TEST_NAME="health 400. LDE-002006 – Неверный запрос. Bad location"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL/health
    f_check -r 400 -m "LDE-002006"
}


if [ -z "$1" ]; then
    f_print_usage
else
    V=0
    while [ -n "$1" ]; do
        case "$1" in
            -t) TYPE="$2"; shift; shift;;
            -m) MNEMONIC="$2"; shift; shift;;
            -a) ACTIONS="$2"; shift; shift;;
            -r) R="$2"; shift; shift;;
            -p) P="$2"; shift; shift;;
            -v) V=1; shift;;
            -vv) V=2; shift;;
            -*) shift;;
            *)  break;;
        esac
    done

    if [ -z "$1" ]; then
        f_print_usage
    else
        URL=$1
        TYPE=${TYPE:-'photo'}

        if [[ "$TYPE" == "a_video" || "$TYPE" == "p_video+a_video" ]]; then
            if [[ "$MNEMONIC" != "move" && "$MNEMONIC" != "text" ]]; then
                echo; echo -e "\033[31mMnemonic for active liveness is not selected or has an incorrect value (option -m  string)\033[0m"
                echo; exit
            else
                echo; echo -e "\033[32mActive liveness detection mnemonic – ${MNEMONIC}\033[0m"
            fi
        fi
 
        if [[ "$MNEMONIC" == "move" ]]; then
            if [[ "$ACTIONS" != "all" && ! "$ACTIONS" =~ ^[1-8](,[1-8])*$ ]]; then
                echo -e "\033[31mActions for move-instructions mnemonic is not selected or has an incorrect value (option -a  string)\033[0m"
                echo; exit
            else
                echo -e "\033[32mMove instructions: ${ACTIONS}\033[0m"
            fi
        elif [[ ( "$MNEMONIC" == "text" ) ]]; then
            echo -e "\033[32mText instruction: numbers-digits\033[0m"
        fi

        TIMEOUT=${2:-1}
        [ -z $R ] && R="v1" # version
        
        if [ -n "$P" ]; then
            BASE_URL="http://$URL/$R/$P/liveness"
        else
            BASE_URL="http://$URL/$R/liveness"
        fi
        
        # if [[ ( -n "$P" ) && ( -n "$VERSION" ) ]]; then
        #     BASE_URL="http://$URL/v$VERSION/$P/liveness"
        # elif [[ ( -n "$P" ) && ( -z "$VERSION" ) ]]; then
        #     BASE_URL="http://$URL/v1/$P/liveness"
        # elif [[ ( -z "$P" ) && ( -n "$VERSION" ) ]]; then
        #     BASE_URL="http://$URL/v$VERSION/liveness"
        # else
        #     BASE_URL="http://$URL/v1/liveness"
        # fi

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
                f_test_passive_liveness_sound $TYPE $SOUND_SCORE_REGEX
            
            elif [ "$TYPE" == "p_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE $PHOTO_SCORE_REGEX

            elif [ "$TYPE" == "a_video" ]; then
                echo; echo; echo "------------ Begin: f_test_active_liveness_video -------------"
                f_test_active_liveness_video $TYPE $MNEMONIC $ACTIONS

            elif [ "$TYPE" == "photo+p_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_photo -------------"
                f_test_passive_liveness_photo $TYPE $PHOTO_SCORE_REGEX
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE $PHOTO_SCORE_REGEX

            elif [ "$TYPE" == "p_video+a_video" ]; then
                echo; echo; echo "------------ Begin: f_test_passive_liveness_video -------------"
                f_test_passive_liveness_video $TYPE $PHOTO_SCORE_REGEX
                echo; echo; echo "------------ Begin: f_test_active_liveness_video -------------"
                f_test_active_liveness_video $TYPE $MNEMONIC $ACTIONS
                
            else
                echo; echo; echo "------------ Begin: f_test_passive_liveness_photo -------------"
                f_test_passive_liveness_photo $TYPE $PHOTO_SCORE_REGEX
            fi
            
            echo -e "\n\nSCORE: success $SUCCESS, error $ERROR"
        fi
    fi
fi
