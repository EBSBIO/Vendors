#!/bin/bash

f_print_usage() {
echo "Usage: $0 [OPTIONS] URL

OPTIONS:
    -t  list        Set test method: all (default), extract, 
    -v, -vv         Verbose

URL                 <ip>:<port>
"
}


f_check_health() {
    VENDOR_URL="http://$URL/v1/pattern/health"
    REQUEST='curl -s '$VENDOR_URL

    start=`date +%s.%N`
    RESULT=$($REQUEST)
    end=`date +%s.%N`

    if [ "$V1" == 1 ]; then
        echo "Test: health.200"
    fi
    if [ "$V2" == 1 ]; then
        echo "Cmd: $REQUEST"
        echo "Result: $RESULT"
        echo "Runtime: 0$(echo "$end - $start" | bc -l)s"
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
            -r)  HTTP_CHECK="1";
                if [ "$RESPONCE_CODE" == "$2" ] ; then
                    HTTP_RESULT="OK"
                else
                    HTTP_RESULT="FAIL (HTTP $RESPONCE_CODE is expected)"
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

    
    if  [ "$HTTP_CHECK" == 1 ] && [ "$HTTP_RESULT" != "OK" ] ||
        [ "$BODY_CHECK" == 1 ] && [ "$BODY_RESULT" != "OK" ] ||
        [ "$MESSAGE_CHECK" == 1 ] && [ "$MESSAGE_RESULT" != "OK" ]; then
        FAIL=1
        ERROR=$(($ERROR+1))
        #echo "HTTP_CHECK = $HTTP_CHECK"
        #echo "HTTP_RESULT = $HTTP_RESULT"
        #echo "BODY_CHECK = $BODY_CHECK"
        #echo "BODY_RESULT = $BODY_RESULT"
        #echo "MESSAGE_CHECK = $MESSAGE_CHECK"
        #echo "MESSAGE_RESULT = $MESSAGE_RESULT"
    else
        FAIL=0
        SUCCES=$(($SUCCES+1))
    fi

    if [ "$HTTP_CHECK" == 1 ] && [ "$HTTP_RESULT" != "OK" ] && [ -n "$FAIL_MESSAGE" ]; then
        HTTP_RESULT="$HTTP_RESULT $FAIL_MESSAGE"
    fi
   
#    if [ "$FAIL" == 1 ] || [ "$V1" == 1 ]; then
#        echo ""
#        echo "Test: $TEST_NAME"
#    fi
   
    if [ "$FAIL" == 1 ] && [ "$V1" == 1 ] || [ "$V2" == 1 ]; then
        echo ""
        echo "Test: $TEST_NAME"
        echo "Cmd: $REQUEST"
        echo "Responce runtime: 0$(echo "$end - $start" | bc -l )s"
        echo "Responce http_code: $RESPONCE_CODE"
        echo "Responce body_msg: $MESSAGE"
    fi

    if [ "$HTTP_CHECK" == 1 ]; then
        if [ "$HTTP_RESULT" != "OK" ] && [ "$V1" == 1 ]; then
            echo "Status http_code: $HTTP_RESULT"
        elif [ "$HTTP_RESULT" != "OK" ] || [ "$V2" == 1 ]; then
            echo "Status http_code: $HTTP_RESULT"
        fi
    fi
    
    if [ "$BODY_CHECK" == 1 ]; then
        if [ "$BODY_RESULT" != "OK" ] && [ "$V1" == 1 ]; then
            echo "Status body: $BODY_RESULT"
        elif [ "$BODY_RESULT" != "OK" ] || [ "$V2" == 1 ]; then
            echo "Status body: $BODY_RESULT"
        fi
    fi

    if [ "$MESSAGE_CHECK" == 1 ]; then
        if [ "$MESSAGE_RESULT" != "OK" ] && [ "$V1" == 1 ]; then
            echo "Status message: $MESSAGE_RESULT"
        elif [ "$MESSAGE_RESULT" != "OK" ] || [ "$V2" == 1 ]; then
            echo "Status message: $MESSAGE_RESULT"
        fi
    fi

#    rm -f $BODY
}


f_test_extract () {
    VENDOR_URL="http://$URL/v1/pattern/extract"
    BODY="tmp/responce_body"


    TEST_NAME="extract.200.JPG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.200.PNG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @resources/photo.png --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.content-type.lowercase.image/png with JPG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" --data-binary @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "We ask you not to check jpg or png, just image"

    TEST_NAME="extract.content-type.lowercase.image/jpeg with PNG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" --data-binary @resources/photo.png --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "we ask you not to check jpg or png, just image"

    TEST_NAME="extract.400.BPE-002003.empty_file"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/empty.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract.400.BPE-003002.no_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/24.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="extract.400.BPE-003003.more_than_one_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/two_face.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"

    TEST_NAME="extract.400.BPE-002001.wrong_content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" --data-binary  @resources/photo.jpg --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="extract.400.BPE-002002.invalid_http_method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary  @resources/photo.jpg --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="extract.400.BPE-002003.sound"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" --data-binary  @resources/sound.wav --output '$BODY' '$VENDOR_URL
    f_check -r 400  -m "BPE-002003"
}




f_test_compare() {
    VENDOR_URL="http://$URL/v1/pattern/compare"
    BODY="tmp/responce_body"
    BIOTEMPLATE="tmp/biotemplate"
    EMPTY="resources/empty"

    # Create template for compare
    REQUEST='curl -s -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @resources/photo.jpg --output '$BIOTEMPLATE' http://'$URL'/v1/pattern/extract'
    eval $REQUEST

    # Tests
    TEST_NAME="compare.200 "
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-9].[0-9]" -f "- Score format double is expected" 

    TEST_NAME="compare.400.BPE-002001.incorrect_content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL 
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="compare.400.BPE-002004.empty_bio_feature"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$EMPTY';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare.400.BPE-002004.empty_bio_template"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare.400.BPE-002004.empty"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$EMPTY';type=application/octet-stream" -F "bio_template=@'$EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare.400.BPE-002002.invalid_http_method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="compare.400.BPE-002004.bio_template_0X00"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@resources/biotemplate_0X00;type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"
}


f_test_verify() {
    VENDOR_URL="http://$URL/v1/pattern/verify"
    BODY="tmp/responce_body"
    BIOTEMPLATE="tmp/biotemplate"
    SAMPLE="resources/photo.jpg"
    EMPTY="resources/empty"

    # Create template
    REQUEST='curl -s -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE' --output '$BIOTEMPLATE' http://'$URL'/v1/pattern/extract'
    eval $REQUEST
    

    TEST_NAME="verify.200"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "\"?[Ss]core\"?:\s?[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="verify.400.invalid_http_method"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE';type=image/jpeg" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="verify.400.BPE-002001.incorrect_content-type"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="verify.400.BPE-002003.empty_file"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="verify.400.BPE-002004.empty_template"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="verify.400.BPE-002004|BPE-002003.empty_all"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$EMPTY';type=application/octet-stream" -F "sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003|BPE-002004"

    TEST_NAME="verify.400.BPE-003002.no_face"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@resources/24.jpg;type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="verify.400.BPE-003003.more_than_one_face"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@resources/two_face.jpg;type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"

    TEST_NAME="verify.400.BPE-002005.invalid_content-type_multipart"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"

   TEST_NAME="verify.200.boundary_no_hyphens"
   cat resources/body_stream $BIOTEMPLATE resources/body_image $SAMPLE resources/body_end > tmp/request_body
   REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
   f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="verify.200.no_filename"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="sample"\r\nContent-Type: image/jpeg\r\n\r\n' >> tmp/request_body; cat $SAMPLE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    RESULT='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
}


if [ -z "$1" ]; then
    f_print_usage
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
        f_print_usage
    else
        URL=$1
        f_check_health
        return_val=$?
        if [ "$return_val" -eq 0 ]; then
            SUCCES=0
            ERROR=0

            case "$TASK" in
            all )
                f_test_extract
                f_test_compare
                f_test_verify
            ;;
            extract )
                f_test_extract
            ;;
            compare )
                f_test_compare
            ;;
            verify )
                f_test_verify
            ;;
            esac
            echo ""; echo ""; echo "SCORE: succes $SUCCES, error $ERROR"
        fi
    fi
fi
