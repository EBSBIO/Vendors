#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

BODY="tmp/responce_body"
SAMPLE_WAV="resources/samples/sound.wav"
SAMPLE_EMPTY="resources/samples/empty"
SAMPLE_SWV="resources/samples/sound_without_voice.wav"
SAMPLE_SDV="resources/samples/sound_double_voice.wav"
SAMPLE_PNG="resources/samples/photo.png"
BIOTEMPLATE="tmp/biotemplate"

f_test_extract () {
    VENDOR_URL="http://$URL/v1/pattern/extract"
    BODY="tmp/responce_body"

    TEST_NAME="Positive extraction test.1 Extract pcm sound"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b
    
    TEST_NAME="Negative extraction test 1. Attempting to extract a template from a file of zero size"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="Negative extraction test 2. Attempting to extract a template from a file without voice"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_SWV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"
    
    TEST_NAME="Negative extraction test 3. Attempting to extract a template from a file with more than one voice"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_SDV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"
    
    TEST_NAME="Negative extraction test 4. Uses in request incorrect content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"
    
    TEST_NAME="Negative extraction test 5. Invalid http request method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_WAV' -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="Negative extraction test 6. Trying to create a template from photo"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_PNG'  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"
}



f_test_compare() {
    VENDOR_URL="http://$URL/v1/pattern/compare"

    # Create template for compare
    REQUEST='curl -s -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BIOTEMPLATE' http://'$URL'/v1/pattern/extract'
    eval $REQUEST

    # Tests
    TEST_NAME="Positive compare"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="Negative compare test 1. Uses in request incorrect content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"
    
    TEST_NAME="Negative compare test 2. Comparing an empty template with a template"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"
    
    TEST_NAME="Negative compare test 3. Comparing a template with an empty template"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="Negative compare test 4. Comparing an empty template with an empty template"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="Negative compare test 5. Invalid http request method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"
    
    TEST_NAME="Negative compare test 6. Invalid Content-Type for bio_feature"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"
    
    TEST_NAME="Negative compare test 7. Invalid Content-Type for bio_template"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=image/jpeg" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"
    
    TEST_NAME="Negative compare test 8. Compare template with sound file"
    REQUEST='curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$SAMPLE_WAV';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"
}



f_test_verify() {
    VENDOR_URL="http://$URL/v1/pattern/verify"

    # Create biotemplate
    REQUEST='curl -s -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BIOTEMPLATE' http://'$URL'/v1/pattern/extract'
    eval $REQUEST
    

    TEST_NAME="verify.200"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/pcm" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "\"?[Ss]core\"?:\s?[0-1].[0-9]"
    
    TEST_NAME="Negative verify test 1. Invalid http request method"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/pcm" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002" -f "Error expected BPE-002002"
    
    TEST_NAME="Negative verify test 2. Uses in request incorrect content-type"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001" -f "Error expected BPE-002001"
    
    TEST_NAME="Negative verify test 3. Attempting to extract a template from a file of zero size"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_EMPTY';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003" -f "Error expected BPE-002003"
    
    TEST_NAME="Negative verify test 4. Trying to compose an empty template with an good sound"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004" -f "Error expected BPE-002004"
    
    TEST_NAME="Negative verify test 5. Comparing an empty template with an empty file"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE_EMPTY';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00200[3-4]"

    TEST_NAME="Negative verify test 6. Attempting to extract a template from a file without voice"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_SWV';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003001"
    
    TEST_NAME="Negative verify test 7. Attempting to extract a template from a file with more than one voice"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_SDV';type="  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"
    
    TEST_NAME="Negative verify test 8. Incorrect Content-Type for sample"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=image/jpeg"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="Negative verify test 9. Incorrect Content-Type for bio_template"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=image/jpeg" -F "sample=@'$SAMPLE_WAV';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="Negative verify test 10. Extract template from photo"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=audio/pcm"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="verify.200.boundary_no_hyphens"
    cat resources/body/body_stream $BIOTEMPLATE resources/body/body_sound $SAMPLE_WAV resources/body/body_end > tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    
    TEST_NAME="verify.200.no_filename"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="sample"\r\nContent-Type: audio/pcm\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
}



f_print_usage() {
echo "Usage: $0 [OPTIONS] URL

OPTIONS:
    -t  list        Set test method: all (default), extract, compare, verify
    -v              Verbose FAIL checks
    -vv             Verbose All checks

URL                 <ip>:<port>
"
}



if [ -z "$1" ]; then
    f_print_usage
else
    TASK="all"
    V=0
    while [ -n "$1" ]; do
        case "$1" in
            -t) TASK="$2"; shift; shift;;
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

        VENDOR_URL="http://$URL/v1/pattern/health"
        BODY="tmp/responce_body"
        TEST_NAME="Healt.200"
        REQUEST='curl -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        f_check -r 200 -m "\"?[Ss]tatus\"?:\s?0"

        if [ "$FAIL" -eq 0 ]; then
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
            echo -e "\n\nSCORE: succes $SUCCES, error $ERROR"
        fi
    fi
fi
