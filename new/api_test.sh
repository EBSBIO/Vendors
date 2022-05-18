#!/bin/bash

print_usage() {
echo "Usage: $0 [OPTIONS] URL

OPTIONS:
    -t  list        Set test method: all (default), extract, 
    -v, -vv         Verbose

URL                 <ip>:<port>/<ver>
"
}


check_health() {
    VENDOR_URL="http://$URL/pattern/health"
    REQUEST='curl -s '$VENDOR_URL

    start=`date +%s.%N`
    RESULT=$($REQUEST)
    end=`date +%s.%N`

    if [ "$V1" == 1 ]; then
        echo "Test: health.200"
    fi
    if [ "$V2" == 1 ]; then
        echo "Request: $REQUEST"
        echo "Result: $RESULT"
        echo "Runtime 0$( echo "$end - $start" | bc -l )s"
    fi
    if [[ $RESULT =~ "0" ]]; then
        if [ "$V1" == 1 ]; then
            echo "Health cheak status: OK"
        fi
        return 0
    else
        echo "Health cheak status: FAIL"
        return 1
    fi
}

check_extract() {
    start=`date +%s.%N`
    RESPONCE_CODE=$(eval $REQUEST)
    end=`date +%s.%N`
   
    unset HTTP_CHECK HTTP_RESULT
    unset BODY_CHECK BODY_RESULT
    unset MESSAGE MESSAGE_CHECK MESSAGE_RESULT
    unset FAIL_MESSAGE

    while [ -n "$1" ]; do
        case "$1" in
            # http responce check
            -r) if [ "$RESPONCE_CODE" == "$2" ] ; then
                    HTTP_CHECK="1";
                    HTTP_RESULT="OK"
                else
                    HTTP_CHECK="0";
                    HTTP_RESULT="FAIL (HTTP $RESPONCE_CODE)"
                fi
                shift
            ;;
            # body weight
            -b)
                if [ -s $BODY ]; then
                    BODY_CHECK=1
                    BODY_RESULT="OK"
                else
                    BODY_CHECK=0
                    BODY_RESULT="FAIL (template is empty)"
                fi
            ;;
            # body message
            -m) if [ -s $BODY ]; then
                    MESSAGE=$(cat $BODY)
                    if [[ $MESSAGE  =~ $2 ]]; then
                        MESSAGE_CHECK=1
                        MESSAGE_RESULT="OK"
                    else
                        MESSAGE_CHECK=0
                        MESSAGE_RESULT="FAIL ($2 is expected)"
                    fi
                else
                    MESSAGE_CHECK=0
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

    
    if  [ "$HTTP_CHECK" == 0 ] || [ "$BODY_CHECK" == 0 ] || [ "$MESSAGE_CHECK" == 0 ]; then
        RESULT_CHECK=0;
        ERROR=$(($ERROR+1))
    else
        RESULT_CHECK=1;
        SUCCES=$(($SUCCES+1))
    fi

    if [ "$HTTP_CHECK" == 0 ] && [ -n "$FAIL_MESSAGE" ]; then
        HTTP_RESULT="$HTTP_RESULT $FAIL_MESSAGE"
    fi
   

    if [ "$RESULT_CHECK" == 0 ] || [ "$V1" == 1 ]; then
        echo ""
        echo "Test: $TEST_NAME"
    fi
    
    if [ "$V2" == 1 ]; then
        echo "Cmd: $REQUEST"
        echo "Http responce: $RESPONCE_CODE"
        echo "Runtime 0$(echo "$end - $start" | bc -l )s"
    fi

    if [ "$HTTP_CHECK" == 0 ] || [ "$V1" == 1 ] &&  [ -n "$HTTP_CHECK"  ] ; then
        echo "Http tatus: $HTTP_RESULT"
    fi 
    
    if [ "$BODY_CHECK" == 0 ]  || [ "$V1" == 1 ] && [ -n "$BODY_CHECK" ]; then
            echo "Body tatus: $BODY_RESULT"
    fi

    if [ "$MESSAGE_CHECK" == 0 ]  || [ "$V1" == 1 ] && [ -n "$MESSAGE_CHECK" ]; then
        echo "Message: $MESSAGE"
        echo "Message status: $MESSAGE_RESULT"
    fi

    rm -f $BODY
}



test_extract () {
    VENDOR_URL="http://$URL/pattern/extract"
    BODY="template/bio_template"
    SUCES=0
    ERROR=0

    TEST_NAME="extract.200.JPG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 200 -b

    TEST_NAME="extract.200.PNG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @resources/photo.png --output '$BODY' '$VENDOR_URL
    check_extract -r 200 -b

    TEST_NAME="extract.content-type.lowercase.image/png with JPG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" --data-binary @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 200 -b -f "We ask you not to check jpg or png, just image"

    TEST_NAME="extract.content-type.lowercase.image/jpeg with PNG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" --data-binary @resources/photo.png --output '$BODY' '$VENDOR_URL
    check_extract -r 200 -b -f "we ask you not to check jpg or png, just image"

    TEST_NAME="extract.400.BPE-002003.empty_file"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/empty.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 400 -m "BPE-002003"

    TEST_NAME="extract.400.BPE-003002.no_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/24.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 400 -m "BPE-003002"

    TEST_NAME="extract.400.BPE-003003.more_than_one_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/two_face.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 400 -m "BPE-003003"

    TEST_NAME="extract.400.BPE-002001.wrong_content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" --data-binary  @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 400 -m "BPE-002001"

    TEST_NAME="extract.400.BPE-002002.invalid_http_method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary  @resources/photo.jpg --output '$BODY' -X GET '$VENDOR_URL
    check_extract -r 400 -m "BPE-002002"

    TEST_NAME="extract.400.BPE-002003.sound"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" --data-binary  @resources/sound.wav --output '$BODY' '$VENDOR_URL
    check_extract -r 400  -m "BPE-002003"



    echo ""
    echo ""
    echo "SCORE: succes $SUCCES, error $ERROR"
}

test_compare() {
    VENDOR_URL="http://$URL/pattern/compare"
    BODY="template/bio_template"
    SUCES=0
    ERROR=0

    TEST_NAME="extract.200.JPG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    check_extract -r 200 -b

    TEST_NAME="compare.200 "
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=resources/bio_template;type=application/octet-stream" -F "bio_template=@resources/bio_template;type=application/octet-stream" -X POST '$VENDOR_URL
    check_extract -r 200 -b

    TEST_NAME="compare.400.BPE-002001.incorrect_content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_feature=@template/bio_template;type=application/octet-stream" -F "bio_template=@template/bio_template;type=application/octet-stream" --output template/bio_template_f -X POST '$VENDOR_URL 
    check_extract -r 400


}

if [ -z "$1" ]; then
    print_usage
else
    TASK="all"
    V1=0
    V2=0
    while [ -n "$1" ]; do
        case "$1" in
            -t) TASK="$2"; shift; shift;;
            -v) V1=1; shift;;
            -vv) V1=1; V2=1; shift;;
            -*) shift;;
            *)  break;;
        esac
    done
    if [ -z "$1" ]; then
        print_usage
    else
        URL=$1
        check_health
        return_val=$?
        if [ "$return_val" -eq 0 ]; then
            case "$TASK" in
            all )
                test_extract
                test_compare;;
#                test_verify;;
#            extract )
#                test_extract;;
#            compare )
#                test_compare;;
#            verify )
#                test_verify;;
            esac
        fi
    fi
fi
