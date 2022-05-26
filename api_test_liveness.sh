#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

f_test_liveness() {
    VENDOR_URL="http://$URL/v1/liveness/detect"
    BODY="tmp/responce_body"
    SAMPLE_JPG="resources/photo_velmozhin.jpg"
    SAMPLE_PNG="resources/photo.png"
    SAMPLE_WAV="resources/sound.wav"
    SAMPLE_WEBM="resources/video.mov"
    META="resources/meta.json"
    META_WM="resources/meta_without_mnemonic.json"
    META_WA="resources/meta_without_action.json"
    META_WT="resources/meta_without_type.json"
    META_WD="resources/meta_without_duration.json"
    META_WMSG="resources/meta_without_message.json"
    EMPTY="resources/empty"

    TEST_NAME="Positive test 1. detect photo.jpeg"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="Positive test 2. detect photo.png"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_PNG';type=image/png" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="Negative test 1. Request with incorrect HTTP method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpg" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002002"

    TEST_NAME="Negative test 2. Request with empty bio_sample"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 3. Incorrect Content-Type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002001"

    TEST_NAME="Negative test 4. Incorrect Content-Type part of multipart"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=image/jpeg" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 5. Incorrect Content-Type part of multipart"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 6. Request with sound"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 7. Request with sound"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 8. Request with video"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WEBM';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 9. Request with video"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WEBM';type=video/webm" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 10. Request with meta without mnemonic"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WM';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002003"

    TEST_NAME="Negative test 11. Request with meta without action"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WA';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002003"

    TEST_NAME="Negative test 12. Request with meta without action.type"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WT';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002003"

    TEST_NAME="Negative test 13. Request with meta without action.duration"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WD';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002003"

    TEST_NAME="Negative test 14. Request with meta without action.message"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WMSG';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002003"
}


f_print_usage() {
echo "Usage: $0 [OPTIONS] URL

    OPTIONS:
        -v              Verbose FAIL checks
        -vv             Verbose All checks

    URL                 <ip>:<port>"
}


if [ -z "$1" ]; then
    f_print_usage
else
    V=0
    while [ -n "$1" ]; do
        case "$1" in
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

        VENDOR_URL="http://$URL/v1/liveness/health"
        BODY="tmp/responce_body"
        TEST_NAME="Healt.200"
        REQUEST='curl -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        f_check -r 200 -m "\"?[Ss]tatus\"?:\s?0"

        if [ "$FAIL" -eq 0 ]; then
            SUCCES=0
            ERROR=0

            f_test_liveness

            echo -e "\n\nSCORE: succes $SUCCES, error $ERROR"
        fi
    fi
fi