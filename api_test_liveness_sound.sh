#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
# version: 1.24.1        #
##########################

# include functions
source include/f_checks.sh

BODY="tmp/responce_body"
EMPTY="resources/samples/empty"
META="resources/metadata/meta_lv_sound_passive.json"
META_WM="resources/metadata/meta_lv_s_p_without_mnemonic.json"
META_WA="resources/metadata/meta_lv_s_p_without_action.json"
META_WT="resources/metadata/meta_lv_s_p_without_type.json"
META_WD="resources/metadata/meta_lv_s_p_without_duration.json"
META_WMSG="resources/metadata/meta_lv_s_p_without_message.json"

SAMPLE_WAV="resources/samples/sound.wav"
SAMPLE_PCM="resources/samples/sound.pcm"
SAMPLE_NV="resources/samples/sound_without_voice.wav"
SAMPLE_DV="resources/samples/sound_double_voice.wav"

SAMPLE_JPG="resources/samples/photo_shumskiy.jpg"
SAMPLE_WEBM="resources/samples/video.mov"
SAMPLE_CAT_JPG="resources/samples/cat.jpg"

f_test_liveness() {
    VENDOR_URL="$BASE_URL/detect"

    TEST_NAME="Positive test 1. detect sound.wav"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    
    TEST_NAME="Positive test 2. detect sound.pcm"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_PCM';type=audio/pcm" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="Positive test 3. detect sound.wav metadata charset=UTF-8"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json;charset=UTF-8" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="Positive test 4. 200.no_filename"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: audio/wav\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

#    TEST_NAME="Negative test 0. Cat photo"
#    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_CAT_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
#    f_check -r 400 -m "LDE-003002"

    TEST_NAME="Negative test 1. Incorrect Content-Type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002001"

    TEST_NAME="Negative test 2. Request with incorrect HTTP method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002002"

    TEST_NAME="Negative test 3. Request with empty bio_sample"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$EMPTY';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 4. Incorrect Content-Type part of multipart"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=image/jpeg" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 5. Incorrect Content-Type part of multipart"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 6. Request with photo"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 7. Request with photo"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 8. Request with video"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WEBM';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="Negative test 9. Request with video"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WEBM';type=video/webm" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="Negative test 10. Request with no voice"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_NV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003002"

    TEST_NAME="Negative test 11. Request with two voice"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_DV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003003"

    TEST_NAME="Negative test 12. Request with meta without mnemonic"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WM';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="Negative test 13. Request with meta without action"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WA';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="Negative test 14. Request with meta without action.type"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WT';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="Negative test 15. Request with meta without action.duration"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WD';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="Negative test 16. Request with meta without action.message"
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WMSG';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"
}


f_print_usage() {
echo "Usage: $0 [OPTIONS] URL

OPTIONS:
    -r  string      Release/Version (from method URL)
    -p  string      Prefix
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
        URL=$1
        [ -z $R ] && R="v1" # version
        
        if [ -n "$P" ]; then
            BASE_URL="http://$URL/$R/$P/liveness"
        else
            BASE_URL="http://$URL/$R/liveness"
        fi
        
#        if [[ ( -n "$P" ) && ( -n "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/v$VERSION/$P/liveness"
#        elif [[ ( -n "$P" ) && ( -z "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/v1/$P/liveness"
#        elif [[ ( -z "$P" ) && ( -n "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/v$VERSION/liveness"
#        else
#            BASE_URL="http://$URL/v1/liveness"
#        fi

        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"
        TEST_NAME="Healt.200"
        REQUEST='curl -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        mkdir -p tmp
        f_check -r 200 -m "\"?[Ss]tatus\"?:\s?0"

        if [ "$FAIL" -eq 0 ]; then
            SUCCES=0
            ERROR=0

            f_test_liveness

            echo -e "\n\nSCORE: succes $SUCCES, error $ERROR"
        fi
    fi
fi
