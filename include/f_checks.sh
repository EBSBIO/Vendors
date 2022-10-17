#!/bin/bash
##########################
# Author: kflirik        #
#                        #
# part-of api_tests      #
##########################

f_check() {
    start=`date +%s.%N`
    RESPONCE_CODE=$(eval $REQUEST)
    end=`date +%s.%N`
   
    FAIL=0
    HTTP_CHECK=0
    BODY_CHECK=0
    MESSAGE_CHECK=0
    unset BODY_RESULT HTTP_RESULT
    unset FAIL_MESSAGE MESSAGE

    while [ -n "$1" ]; do
        case "$1" in
            # http responce check
            -r) HTTP_CHECK="1";
                REQUEST_CODE=$2
                if [ "$RESPONCE_CODE" == "$REQUEST_CODE" ] ; then
                    HTTP_RESULT="OK"
                else
                    HTTP_RESULT="FAIL (HTTP $REQUEST_CODE is expected)"
                fi
                shift
            ;;
            # body weight
            -b) BODY_CHECK=1
                if [ -s $BODY ]; then
                    BODY_RESULT="OK"
                else
                    BODY_RESULT="FAIL (template is empty)"
                fi
            ;;
            # body message
            -m) MESSAGE_CHECK=1
                if [ -s $BODY ]; then
                    #MESSAGE=$(head -n 5 $BODY)
                    #cat $BODY
                    MESSAGE=$(grep --binary-files=text -e '{.*}' $BODY)
                    if [[ $MESSAGE  =~ $2 ]]; then
                        MESSAGE_RESULT="OK"
                    else
                        MESSAGE_RESULT="FAIL ($2 is expected)"
                    fi
                else
                    MESSAGE_RESULT="FAIL (message does not exist)"
                fi
                shift
            ;;
            # fail message
            -f) FAIL_MESSAGE="$2";
                shift
            ;;
        esac
        shift
    done

    if  [[ ( "$HTTP_CHECK" == 1 && "$HTTP_RESULT" != "OK" ) || ( "$BODY_CHECK" == 1 && "$BODY_RESULT" != "OK" ) || ( "$MESSAGE_CHECK" == 1 && "$MESSAGE_RESULT" != "OK" ) ]]; then
        FAIL=1
        ERROR=$(($ERROR+1))
    else
        FAIL=0
        SUCCESS=$(($SUCCESS+1))
    fi

    if [ "$MESSAGE_CHECK" == 1 ] && [ "$MESSAGE_RESULT" != "OK" ] && [ -n "$FAIL_MESSAGE" ]; then
        MESSAGE_RESULT="$MESSAGE_RESULT $FAIL_MESSAGE"
    fi
   
    if [[ ( "$FAIL" == 1 && "$V" == 1 ) || "$V" == 2 ]]; then
        echo ""
        echo "Test: $TEST_NAME"
        echo "Cmd: $REQUEST"
        echo "Responce runtime: 0$(echo "$end - $start" | bc -l )s"
        echo "Responce http_code: $RESPONCE_CODE"
        echo "Responce body_msg: $MESSAGE"
    elif [ "$FAIL" == 1 ]; then
        echo ""
        echo "Test: $TEST_NAME"
    fi

    if [ "$HTTP_CHECK" == 1 ]; then
        if [ "$HTTP_RESULT" != "OK" ]; then
            echo "Status http_code: $HTTP_RESULT"
        elif [ "$V" == 2 ]; then
            echo "Status http_code: $HTTP_RESULT"
        fi
    fi
    
    if [ "$BODY_CHECK" == 1 ]; then
        if [ "$BODY_RESULT" != "OK" ]; then
            echo "Status body: $BODY_RESULT"
        elif [ "$V" == 2 ]; then
            echo "Status body: $BODY_RESULT"
        fi
    fi

    if [ "$MESSAGE_CHECK" == 1 ]; then
        if [ "$MESSAGE_RESULT" != "OK" ]; then
            echo "Status message: $MESSAGE_RESULT"
        elif [ "$V" == 2 ]; then
            echo "Status message: $MESSAGE_RESULT"
        fi
    fi

    rm -f $BODY
}
