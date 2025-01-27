#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

HEALTH_REGEX='\{\s*"status":\s?0(,\s*"message":.*)?\s*\}'
SCORE_REGEX='\{\s*"score":\s?((0\.0)|(0\.[0-9]*[1-9]+)|(1\.0))\s*\}'

BODY="tmp/responce_body"
SAMPLE_WAV="resources/samples/sound.wav"
SAMPLE_WAV_WFE="resources/samples/wav_sound_wfe"
SAMPLE_EMPTY="resources/samples/empty"
SAMPLE_SWV="resources/samples/sound_without_voice.wav"
SAMPLE_SDV="resources/samples/sound_double_voice.wav"
SAMPLE_PNG="resources/samples/photo.png"
SAMPLE_JPG="resources/samples/photo.jpg"
VERTICAL_SAMPLE_MOV="resources/samples/vert_passive_video"
BIOTEMPLATE="tmp/biotemplate"


f_test_health() {
    VENDOR_URL="$BASE_URL/health"
    
    TEST_NAME="health 400. BPE-002006 – Неверный запрос. Bad location"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL/health
    f_check -r 400 -m "BPE-002006"
}


f_test_extract() {
    VENDOR_URL="$BASE_URL/extract"
    BODY="tmp/responce_body"

    TEST_NAME="extract 200. WAV sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b
    
    \cp $SAMPLE_WAV $SAMPLE_WAV_WFE
    TEST_NAME="extract 200. WAV sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_WAV_WFE' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b
    rm -f $SAMPLE_WAV_WFE

    TEST_NAME="extract 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="extract 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_WAV' -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="extract 400. BPE-002003 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract 400. BPE-002003 – Не удалось прочитать биометрический образец. Photo file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_PNG'  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract 400. BPE-002003 – Не удалось прочитать биометрический образец. Video file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$VERTICAL_SAMPLE_MOV'  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract 400. BPE-003002 – На биометрическом образце отсутствует голос. No voice"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_SWV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"
    
    #TEST_NAME="extract 400. BPE-003003 – На биометрическом образце присутствует более, чем один голос. More than one voice"
    #REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @'$SAMPLE_SDV' --output '$BODY' '$VENDOR_URL
    #f_check -r 400 -m "BPE-003003"
}


f_test_compare() {
    VENDOR_URL="$BASE_URL/extract"

    # Create template for compare
    REQUEST='curl -m '$TIMEOUT' -s -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BIOTEMPLATE' '$VENDOR_URL
    eval $REQUEST

    VENDOR_URL="$BASE_URL/compare"

    # Tests
    TEST_NAME="compare 200"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Without filename parameter"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_feature"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Without filename parameter with boundary in quotes"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_feature"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=\"72468\"" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Reverse order of headings without filename"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_feature"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Reverse order of headings with filename 1"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_feature"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"; filename="biotemplate"\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Reverse order of headings with filename 2"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_feature"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 200. Reverse order of headings with filename 3"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_feature"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"; filename="biotemplate"\r\n\r\n' >> tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="compare 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="compare 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="compare 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Empty biofeature"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Empty biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"
    
    TEST_NAME="compare 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Empty templates"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Invalid biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$SAMPLE_WAV';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="compare 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid biofeature type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="compare 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid biotemplate type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@'$BIOTEMPLATE';type=application/octet-stream" -F "bio_template=@'$BIOTEMPLATE';type=image/jpeg" -X POST --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
}


f_test_verify() {
    VENDOR_URL="$BASE_URL/extract"

    # Create biotemplate
    REQUEST='curl -m '$TIMEOUT' -s -H "Content-Type:audio/wav" -H "Expect:" --data-binary @'$SAMPLE_WAV' --output '$BIOTEMPLATE' '$VENDOR_URL
    eval $REQUEST

    VENDOR_URL="$BASE_URL/verify"

    TEST_NAME="verify 200. WAV sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"
    
    \cp $SAMPLE_WAV $SAMPLE_WAV_WFE
    TEST_NAME="verify 200. WAV sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV_WFE';type=audio/wav" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"
    rm -f $SAMPLE_WAV_WFE

    TEST_NAME="verify 200. Boundary no hyphens"
    cat resources/body/body_stream $BIOTEMPLATE resources/body/body_sound $SAMPLE_WAV resources/body/body_end > tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"
    
    TEST_NAME="verify 200. Without filename parameter"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="sample"\r\nContent-Type: audio/wav\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 200. Without filename parameter with boundary in quotes"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="bio_template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="sample"\r\nContent-Type: audio/wav\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=\"72468\"" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 200. Reverse order of headings without filename"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: audio/wav\r\nContent-Disposition: form-data; name="sample"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 200. Reverse order of headings with filename 1"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: audio/wav\r\nContent-Disposition: form-data; name="sample"; filename="sound.wav"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 200. Reverse order of headings with filename 2"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: audio/wav\r\nContent-Disposition: form-data; name="sample"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 200. Reverse order of headings with filename 3"
    echo -ne '--72468\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="bio_template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: audio/wav\r\nContent-Disposition: form-data; name="sample"; filename="sound.wav"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_WAV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="verify 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001" -f "Error expected BPE-002001"

    TEST_NAME="verify 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/wav" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002" -f "Error expected BPE-002002"

    TEST_NAME="verify 400. BPE-002003 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_EMPTY';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003" -f "Error expected BPE-002003"

    TEST_NAME="verify 400. BPE-002003 – Не удалось прочитать биометрический образец. Photo file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_JPG';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="verify 400. BPE-002003 – Не удалось прочитать биометрический образец. Video file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$VERTICAL_SAMPLE_MOV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="verify 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Empty biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004" -f "Error expected BPE-002004"

    TEST_NAME="verify 400. BPE-002004 – Не удалось прочитать биометрический шаблон | BPE-002003 – Не удалось прочитать биометрический образец. Empty all"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$SAMPLE_EMPTY';type=application/octet-stream" -F "sample=@'$SAMPLE_EMPTY';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00200[3-4]"

    TEST_NAME="verify 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid biotemplate type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=image/jpeg" -F "sample=@'$SAMPLE_WAV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"

    TEST_NAME="verify 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_WAV';type=image/jpeg"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"
    
    TEST_NAME="verify 400. BPE-003002 – На биометрическом образце отсутствует голос. No voice"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_SWV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"
    
    #TEST_NAME="verify 400. BPE-003003 – На биометрическом образце присутствует более, чем один голос. More than one voice"
    #REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@'$BIOTEMPLATE';type=application/octet-stream" -F "sample=@'$SAMPLE_SDV';type=audio/wav"  --output '$BODY' '$VENDOR_URL
    #f_check -r 400 -m "BPE-003003"
}


f_print_usage() {
echo "Usage: $0 [OPTIONS] URL TIMEOUT

OPTIONS:
    -t  string      Set test method: all (default), health, extract, compare, verify
    -r  string      Release/Version (from method URL)
    -p  prefix      Prefix
    -v              Verbose FAIL checks
    -vv             Verbose All checks

URL                 <ip>:<port>
TIMEOUT             <seconds> – maximum time in seconds that you allow the whole operation to take
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
        TIMEOUT=$2
        [ -z $R ] && R="v1" # version
        
        if [ -n "$P" ]; then
            BASE_URL="http://$URL/$R/$P/pattern"
        else
            BASE_URL="http://$URL/$R/pattern"
        fi

#        if [[ ( -n "$P" ) && ( -n "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/$VERSION/$P/pattern"
#        elif [[ ( -n "$P" ) && ( -z "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/v1/$P/pattern"
#        elif [[ ( -z "$P" ) && ( -n "$VERSION" ) ]]; then
#            BASE_URL="http://$URL/$VERSION/pattern"
#        else
#            BASE_URL="http://$URL/v1/pattern"
#        fi
        
        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"
        TEST_NAME="Health 200"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        mkdir -p tmp
        f_check -r 200 -m ${HEALTH_REGEX}

        if [ "$FAIL" -eq 0 ]; then
            SUCCESS=0
            ERROR=0

            case "$TASK" in
            all )
                echo; echo; echo "------------ Begin: f_test_health -------------"
                f_test_health
                echo; echo; echo "------------ Begin: f_test_extract -------------"
                f_test_extract
                echo; echo; echo "------------ Begin: f_test_compare -------------"
                f_test_compare
                echo; echo; echo "------------ Begin: f_test_verify -------------"
                f_test_verify
            ;;
            health ) 
                f_test_health
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
            echo -e "\n\nSCORE: success $SUCCESS, error $ERROR"
        fi
    fi
fi
