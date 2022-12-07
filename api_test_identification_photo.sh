#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
# Ver: 1.24.2            #
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

SAMPLE_BR="tmp/photo_br.jpg"
BIOTEMPLATE_BR="tmp/biotemplate_br"

META=\''metadata={"template_id":"12345"};type=application/json'\'
META_BIGID=\''metadata={"template_id":"12345100500"};type=application/json'\'
META_NOID=\''metadata={"id":"12345"};type=application/json'\'
META_EMPTY=\''metadata=;type=application/json'\'
META_BAD=\''metadata={"template_id":"12345",};type=application/json'\'
META_BROKEN=\''metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json'\'
META_IPV=\''metadata={"template_id":"HFS_@#-12345"};type=application/json'\'

MMETA=\''metadata={"threshold": 0.3, "limit": 5};type=application/json'\'
MMETA_NOLIM=\''metadata={"threshold": 0.3};type=application/json'\'
MMETA_NOTH=\''metadata={"limit": 5};type=application/json'\'
MMETA_BAD=\''metadata={"threshold": 0.3, "limit": 5,};type=application/json'\'
MMETA_BADTYPE=\''metadata={"threshold": 0.3, "limit": 5};type=image/jpeg'\'

RDATA=\''{"template_id": "12345"}'\'
RDATA_BIG=\''{"template_id": "12345100500"}'\'
RDATA_NOID=\''{"id":"12345"}'\'
RDATA_BAD=\''{"template_id":"12345",}'\'
RDATA_BROKEN=\''{"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="}'\'


f_test_extract () {
    VENDOR_URL="$BASE_URL/extract"
    BODY="tmp/responce_body"

    TEST_NAME="extract.200.JPG"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.200.PNG"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract.content-type.lowercase.image/png with JPG"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "We ask you not to check jpg or png, just image"

    TEST_NAME="extract.content-type.lowercase.image/jpeg with PNG"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "we ask you not to check jpg or png, just image"
    
    TEST_NAME="extract.400.BPE-002001.wrong_content-type"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" --data-binary  @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="extract.400.BPE-002002.invalid_http_method"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary  @'$SAMPLE_JPG' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="extract.400.BPE-002003.empty_file"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="extract.400.BPE-002003.sound"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 400  -m "BPE-002003"

    #TEST_NAME="extract.400.BPE-003001.no_face"
    #REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_NF' --output '$BODY' '$VENDOR_URL
    #f_check -r 400 -m "BPE-003002"

    TEST_NAME="extract.400.BPE-003002.no_face"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_NF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="extract.400.BPE-003003.more_than_one_face"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_TF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"

}


f_test_add() {
    VENDOR_URL="$BASE_URL/add"
    
    ###### Prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    TEST_NAME="PREPARE - delete template_id: 12345"
    RDATA_BIG=\''{"template_id": "12345"}'\'
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a" --data '$RDATA_BIG' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    ##### TESTS
    TEST_NAME="add.200"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
#    TEST_NAME="PREPARE - add biotemplate"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
#    f_check -r 200

    TEST_NAME="add.400.BPE-002001 Неверный Content-Type HTTP-запроса"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:ppplication/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="add.400.BPE-002002 Неверный метод HTTP-запроса"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="add.400.BPE-002004 Не удалось прочитать биометрический шаблон"
    curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --output $BODY --data $META $BASE_URL/delete
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="add.400.BPE-00005.broken"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="add.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="add.400.BPE-00502 "
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

#    TEST_NAME="add.400.BPE-00502.no_template_file"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL 
#    f_check -r 400 -m "BPE-00502"

    TEST_NAME="add.400.BPE-00502.no_template_part"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="add.400.BPE-00502.no_meta_file"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="add.400.BPE-00502.no_meta_part"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"
    
    TEST_NAME="add.400.BPE-00506"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_IPV' --output '$BODY' '$VENDOR_URL

    TEST_NAME="add.400.BPE-00507"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL 
    f_check -r 400 -m "BPE-00507"
}


f_test_update() {
    VENDOR_URL="$BASE_URL/update"

    ###### Prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    head --bytes=64 $BIOTEMPLATE > $BIOTEMPLATE_BR

    TEST_NAME="PREPARE - delete template_id: 12345"
    RDATA_BIG=\''{"template_id": "12345"}'\'
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a" --data '$RDATA_BIG' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200


    ###### TESTS
    TEST_NAME="update.200"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update.400.BPE-002001"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:pplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="update.400.BPE-002002"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="update.400.BPE-002004"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE_BR';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="update.400.BPE-002404"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BIGID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002404"

    TEST_NAME="update.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="update.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="update.400.BPE-00502.no_template_id"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

#    TEST_NAME="update.400.BPE-00502.no_template_data"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
##    f_check -r 400 -m "BPE-00502"

    TEST_NAME="update.400.BPE-00502.no_template_form"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="update.400.BPE-00502.no_meta_data"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F "metadata=;type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="update.400.BPE-00502.no_meta_form"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

#    TEST_NAME="update.400.BPE-00506.invalid_param_value"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_IPV' --output '$BODY' '$VENDOR_URL
#    f_check -r 400 -m "BPE-00506"
}


f_test_delete() {
    VENDOR_URL="$BASE_URL/delete"

    ###### Prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    TEST_NAME="PREPARE - delete template_id: 12345"
    RDATA_BIG=\''{"template_id": "12345"}'\'
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a" --data '$RDATA_BIG' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200


    ##### TESTS
    TEST_NAME='delete.200'
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '$RDATA' --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="delete.400.BPE-002002"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '$RDATA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="delete.400.BPE-002404"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '$RDATA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002404"

    TEST_NAME="delete.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '$RDATA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="delete.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '$RDATA_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="delete.400.BPE-00502"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" --data '$RDATA_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    #TEST_NAME="update.400.BPE-00506.invalid_param_value"
    #REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data "{"template_id":"HFS_@#-12345"}" --output '$BODY' '$VENDOR_URL
    #f_check -r 400 -m "BPE-00506"
}


f_test_match(){
    VENDOR_URL="$BASE_URL/match"

    ###### Prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    head --bytes=64 $BIOTEMPLATE > $BIOTEMPLATE_BR
    
    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200


    ##### TESTS
    TEST_NAME="match.200"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- format double is expected"

    TEST_NAME="match.400.BPE-002001"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:ppplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="match.400.BPE-002002"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="match.400.BPE-002004"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE_BR';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002004"

    TEST_NAME="match.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="match.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

#    TEST_NAME="match.400.BPE-00005.no_template"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$EMPTY';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
#    f_check -r 400 -m "BPE-00005"

    TEST_NAME="match.400.BPE-00502.no_limit"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_NOLIM' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="match.400.BPE-00502.no_threshold"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_NOTH' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="match.400.BPE-00502.no_template"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="match.400.BPE-00502.no_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F "metadata={};type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

#    TEST_NAME="match.400.BPE-00506"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
#    f_check -r 400 -m "BPE-00506"

}



f_test_identify(){
    VENDOR_URL="$BASE_URL/identify"

    ###### Prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    dd if=/dev/urandom of=$SAMPLE_BR bs=1024 count=4 status=none

    TEST_NAME="PREPARE - delete template_id: 12345"
    RDATA_BIG=\''{"template_id": "12345"}'\'
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a" --data '$RDATA_BIG' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200
    
    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200
    
    #### TESTS
    TEST_NAME="identify.200"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-9].[0-9]" -f "- format double is expected"

    TEST_NAME="identify.400.BPE-002001"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:part/fordata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002001"

    TEST_NAME="identify.400.BPE-002002"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "BPE-002002"

    TEST_NAME="identify.400.BPE-002003"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_BR';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="identify.400.BPE-002005.sample"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=audio/pcm" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"

    TEST_NAME="identify.400.BPE-002005.metadata_type"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=iage/jpeg" -F '$MMETA_BADTYPE' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"

    TEST_NAME="identify.400.BPE-002005.sample_type"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=audio/wav" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002005"

    TEST_NAME="identify.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="identify.400.BPE-00005.bad_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00005"

    TEST_NAME="identify.400.BPE-00502.no_treshold"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_NOTH' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="identify.400.BPE-00502.no_limit"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_NOLIM' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="identify.400.BPE-00502.no_photo"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$EMPTY';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="identify.400.BPE-00502.no_photo"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="identify.400.BPE-00502.no_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F "metadata=;type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

    TEST_NAME="identify.400.BPE-00502.no_meta"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-00502"

#    TEST_NAME="match.400.BPE-00506"
#    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output "$BODY" '$VENDOR_URL
#    f_check -r 400 -m "BPE-00506"

    TEST_NAME="identify.400.BPE-002003.emty"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$EMPTY';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="identify.400.BPE-002003.audio"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_WAV';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-002003"

    TEST_NAME="identify.400.BPE-003002"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_NF';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003002"

    TEST_NAME="identify.400.BPE-003003"
    REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F "photo=@'$SAMPLE_TF';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "BPE-003003"
}




f_print_usage() {
echo "Usage: $0 [OPTIONS] URL TIMEOUT

OPTIONS:
    -t  string      Set test method: all (default), extract, add, update, delete, match, identify
    -p  string      Prefix
    -v              Verbose FAIL checks
    -vv             Verbose All checks

URL                 <ip>:<port>
TIMEOUT             <seconds> Maximum time in seconds that you allow the whole operation to take.
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
        TIMEOUT=$2
        [ -z $R ] && R="v1" # version
        
        if [ -n "$P" ]; then
            BASE_URL="http://$URL/$R/$P/pattern"
            #BASE_URL="http://$URL/$R/$P"
        else
            BASE_URL="http://$URL/$R/pattern"
            #BASE_URL="http://$URL/$R"
        fi

        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"
        TEST_NAME="Healt.200"
        REQUEST='curl -m $TIMEOUT -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL
        mkdir -p tmp
        f_check -r 200 -m "\"?[Ss]tatus\"?:\s?0"

        if [ "$FAIL" -eq 0 ]; then
            SUCCESS=0
            ERROR=0

            case "$TASK" in
            all )
                echo "------------ Begin: f_test_extract -------------"
                f_test_extract
                echo "------------ Begin: f_test_add -------------"
                f_test_add
                echo "------------ Begin: f_test_update -------------"
                f_test_update
                echo "------------ Begin: f_test_delete -------------"
                f_test_delete
                echo "------------ Begin: f_test_match -------------"
                f_test_match
                echo "------------ Begin: f_test_identify -------------"
                f_test_identify
            ;;
            extract ) f_test_extract;;
            add ) f_test_add;;
            update ) f_test_update;;
            delete ) f_test_delete;;
            match ) f_test_match;;
            identify ) f_test_identify;;
            esac
            echo -e "\n\nSCORE: success $SUCCESS, error $ERROR"
        fi
    fi
fi
