#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

BODY="tmp/responce_body"
SAMPLE_JPG="resources/samples/photo.jpg"
SAMPLE_PNG="resources/samples/photo.png"
SAMPLE_WAV="resources/samples/sound.wav"
SAMPLE_WEBM="resources/samples/video.mov"
SAMPLE_NF="resources/samples/no_face.jpg"
SAMPLE_TF="resources/samples/two_face.jpg"
EMPTY="resources/samples/empty"
BIOTEMPLATE="tmp/biotemplate"
BIOTEMPLATE_0X00="resources/biotemplate_0X00"


f_test_extract () {
    VENDOR_URL="$BASE_URL/extract"
    BODY="tmp/responce_body"

    TEST_NAME="extract.200.JPG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.200.PNG"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.content-type.lowercase.image/png with JPG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "We ask you not to check jpg or png, just image"

    TEST_NAME="extract.content-type.lowercase.image/jpeg with PNG"
    REQUEST='curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "we ask you not to check jpg or png, just image"

    TEST_NAME="extract.400.BPE-002003.empty_file"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract.400.BPE-003002.no_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_NF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="extract.400.BPE-003003.more_than_one_face"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_TF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"

    TEST_NAME="extract.400.BPE-002001.wrong_content-type"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" --data-binary  @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="extract.400.BPE-002002.invalid_http_method"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary  @'$SAMPLE_JPG' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="extract.400.BPE-002003.sound"
    REQUEST='curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 400  -m "BPE-002003"
}



f_test_compare() {
    VENDOR_URL="$BASE_URL/extract"

    # Create template for compare
    REQUEST='curl -s -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$VENDOR_URL
    eval $REQUEST
   
    VENDOR_URL="$BASE_URL/compare"

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
    REQUEST='curl -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE_0X00';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"
    
    TEST_NAME="compare.200.no_filename"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_feature"\r\nContent-Type: application/octet-stream\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
}



f_test_verify() {
    VENDOR_URL="$BASE_URL/extract"

    # Create biotemplate
    REQUEST='curl -s -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$VENDOR_URL
    eval $REQUEST
    
    VENDOR_URL="$BASE_URL/verify"
    

    TEST_NAME="verify.200"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "\"?[Ss]core\"?:\s?[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="verify.400.invalid_http_method"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=image/jpeg" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="verify.400.BPE-002001.incorrect_content-type"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="verify.400.BPE-002003.empty_file"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="verify.400.BPE-002004.empty_template"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="verify.400.BPE-002004|BPE-002003.empty_all"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$EMPTY';type=application/octet-stream" -F "sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003|BPE-002004"

    TEST_NAME="verify.400.BPE-003002.no_face"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_NF';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="verify.400.BPE-003003.more_than_one_face"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_TF';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"

    TEST_NAME="verify.400.BPE-002005.invalid_content-type_multipart"
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="verify.200.boundary_no_hyphens"
    cat resources/body/body_stream $BIOTEMPLATE resources/body/body_image $SAMPLE_JPG resources/body/body_end > tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="verify.200.no_filename"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="sample"\r\nContent-Type: image/jpeg\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

}



f_print_usage() {
echo "Usage: $0 [OPTIONS] URL

OPTIONS:
    -t  string      Set test method: all (default), extract, compare, verify
    -p  string      Prefix
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
