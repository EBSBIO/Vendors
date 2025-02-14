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

HEALTH_REGEX='\{\s*"status":\s?0(,\s*"message":.+)?\s*\}'
MATCH_REGEX_PART='\{\s*"template_id":\s?"[a-f0-9]*",\s*"similarity":\s?((0\.0)|(0\.[0-9]*[1-9]+)|(1\.0))\s*\}'
MATCH_REGEX='\[\s*'${MATCH_REGEX_PART}'(,\s*'${MATCH_REGEX_PART}')*\s*\]'
MATCH_REGEX_1_0='(\[\s*'${MATCH_REGEX_PART}'(,\s*'${MATCH_REGEX_PART}')*\s*\])|(\[\])'

f_err_regex() {
    local_code=$1
    local_message=$2

    echo '\{\s*"code":\s?"'${local_code}'",\s*"message":\s?"'${local_message}'"\s*\}'
}

BODY="tmp/responce_body"
SAMPLE_JPG="resources/samples/photo.jpg"
SAMPLE_JPG_2="resources/samples/photo_shumskiy.jpg"
SAMPLE_PNG="resources/samples/photo.png"
SAMPLE_JPG_WFE="resources/samples/jpeg_photo_wfe"
SAMPLE_PNG_WFE="resources/samples/png_photo_wfe"
BIG_SAMPLE_PNG="resources/samples/big.png"
SAMPLE_LSF="resources/samples/little_second_face.jpg"
SAMPLE_WAV="resources/samples/sound.wav"
SAMPLE_WEBM="resources/samples/video.mov"
SAMPLE_NF="resources/samples/no_face.jpg"
SAMPLE_TF="resources/samples/two_face.jpg"
EMPTY="resources/samples/empty"
BIOTEMPLATE="tmp/biotemplate"
ANOTHER_BIOTEMPLATE="tmp/another_biotemplate"

SAMPLE_BR="tmp/photo_br.jpg"
BIOTEMPLATE_BR="tmp/biotemplate_br"

META=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd70"};type=application/json'\'
META_2=\''metadata={"template_id":"1234510050067890"};type=application/json'\'
META_WITH_CHARSET_1=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd70"};type=application/json;charset=UTF-8'\'
META_WITH_CHARSET_2=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd70"};type=application/json; charset=UTF-8'\'
META_ID='{"template_id": "722852fdf2ca4900be3707d80243fd70"}'
META_BIGID=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd7"};type=application/json'\'
META_BADTYPE=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd70"};type=ppplication/gson'\'
META_NOID=\''metadata={"id":"722852fdf2ca4900be3707d80243fd70"};type=application/json'\'
META_EMPTY=\''metadata=;type=application/json'\'
META_BAD=\''metadata={"template_id":"722852fdf2ca4900be3707d80243fd70",};type=application/json'\'
META_BROKEN=\''metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json'\'
META_IPV=\''metadata={"template_id":1234510050067890};type=application/json'\'

MMETA=\''metadata={"threshold": 0.3, "limit": 5};type=application/json'\'
MMETA_WITH_CHARSET_1=\''metadata={"threshold": 0.3, "limit": 5};type=application/json;charset=UTF-8'\'
MMETA_WITH_CHARSET_2=\''metadata={"threshold": 0.3, "limit": 5};type=application/json; charset=UTF-8'\'
MMETA_NUMBER=\''metadata={"threshold": 0.3, "limit": 5E1};type=application/json'\'
MMETA_00=\''metadata={"threshold": 0.0, "limit": 5};type=application/json'\'
MMETA_10=\''metadata={"threshold": 1.0, "limit": 5};type=application/json'\'
MMETA_ID='{"threshold": 0.3, "limit": 5}'
MMETA_ID_2='{"threshold": 0.0, "limit": 5}'
MMETA_NOLIM=\''metadata={"threshold": 0.3};type=application/json'\'
MMETA_NOTH=\''metadata={"limit": 5};type=application/json'\'
MMETA_BAD=\''metadata={"threshold": 0.3, "limit": 5,};type=application/json'\'
MMETA_BADTYPE=\''metadata={"threshold": 0.3, "limit": 5};type=image/jpeg'\'
MMETA_IPV=\''metadata={"threshold": 0.3, "limit": "5"};type=application/json'\'

RDATA=\''{"template_id": "722852fdf2ca4900be3707d80243fd70"}'\'
RDATA_2=\''{"template_id": "1234510050067890"}'\'
RDATA_BIG=\''{"template_id": "722852fdf2ca4900be3707d80243fd7"}'\'
RDATA_NOID=\''{"id":"722852fdf2ca4900be3707d80243fd70"}'\'
RDATA_BAD=\''{"template_id":"722852fdf2ca4900be3707d80243fd70",}'\'
RDATA_BROKEN=\''{"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="}'\'
RDATA_IPV=\''{"template_id": 1234510050067890}'\'


f_test_health() {
    VENDOR_URL="$BASE_URL/health"
    
    TEST_NAME="health 400. BPE-002006 – Неверный запрос. Bad location"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" --output '$BODY' '$VENDOR_URL/health
    f_check -r 400 -m "$(f_err_regex 'BPE-002006' 'Неверный запрос')"
}


f_test_extract() {
    VENDOR_URL="$BASE_URL/extract"
    BODY="tmp/responce_body"

    TEST_NAME="extract 200. JPG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract 200. JPG sample and without X-Request-ID"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: image/jpeg" -H "Expect:" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract 200. PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    \cp $SAMPLE_JPG $SAMPLE_JPG_WFE
    TEST_NAME="extract 200. JPG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG_WFE' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b
    rm -f $SAMPLE_JPG_WFE

    \cp $SAMPLE_PNG $SAMPLE_PNG_WFE
    TEST_NAME="extract 200. PNG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_PNG_WFE' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b
    rm -f $SAMPLE_PNG_WFE

    TEST_NAME="extract 200. Big PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$BIG_SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract 200. Little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_LSF' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b

    TEST_NAME="extract 200. Content-type lowercase image/png with JPG"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "We ask you not to check jpg or png, just image"

    TEST_NAME="extract 200. Content-type lowercase image/jpeg with PNG"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_PNG' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -b -f "we ask you not to check jpg or png, just image"
    
    TEST_NAME="extract 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary  @'$SAMPLE_JPG' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="extract 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary  @'$SAMPLE_JPG' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="extract 400. BPE-002003 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002003' 'Не удалось прочитать биометрический образец')"

    TEST_NAME="extract 400. BPE-002003 – Не удалось прочитать биометрический образец. Sound file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_WAV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002003' 'Не удалось прочитать биометрический образец')"

    TEST_NAME="extract 400. BPE-003002 – На биометрическом образце отсутствует лицо. No face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_NF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-003002' 'На биометрическом образце отсутствует лицо')"

    TEST_NAME="extract 400. BPE-003003 – На биометрическом образце присутствует более, чем одно лицо. More than one face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_TF' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-003003' 'На биометрическом образце присутствует более, чем одно лицо')"
}


f_test_add() {
    VENDOR_URL="$BASE_URL/add"
    
    ###### prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    TEST_NAME="PREPARE - create another biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG_2' --output '$ANOTHER_BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    ###### tests
    TEST_NAME="add 200. With filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200
    
    TEST_NAME="add 200. Without filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. Without filename parameter with boundary in quotes"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=\"------------------------516695485518814e\"" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. Reverse order of headings without filename"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. Reverse order of headings with filename 1"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. Reverse order of headings with filename 2"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. Reverse order of headings with filename 3"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_WITH_CHARSET_1' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_WITH_CHARSET_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="add 200"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="add 200. ID made of digits"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="add 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:ppplication/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="add 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="add 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002004' 'Не удалось прочитать биометрический шаблон')"

    TEST_NAME="add 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid template type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=image/jpeg" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="add 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BADTYPE' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="add 400. BPE-00005 – Не удалось прочитать метаданные. No parameters"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="add 400. BPE-00005 – Не удалось прочитать метаданные. Extra comma in metadata"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="add 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. Bad parameter \"template_id\""
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    # TEST_NAME="add 400. BPE-00502. No template file"
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL 
    # f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="add 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No template part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="add 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata body"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="add 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"
    
    TEST_NAME="add 400. BPE-00506 – Недопустимое значение параметра {название параметра}. Invalid template_id parameter value"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_IPV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00506' 'Недопустимое значение параметра.+')"

    TEST_NAME="add 400. BPE-00507 – Шаблон не добавлен. Запись с данным идентификатором уже существует в базе. Duplicate template_id"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00507' 'Шаблон не добавлен. Запись с данным идентификатором уже существует в базе')"

    TEST_NAME="add 400. BPE-00507 – Шаблон не добавлен. Запись с данным идентификатором уже существует в базе. Duplicate template_id but different vector"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$ANOTHER_BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00507' 'Шаблон не добавлен. Запись с данным идентификатором уже существует в базе')"

    ###### cleaning
    if [[ "$TASK" == "add" ]]; then
        TEST_NAME="CLEANING - delete template_id: 722852fdf2ca4900be3707d80243fd70"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200

        TEST_NAME="CLEANING - delete template_id: 1234510050067890"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_2' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200
    fi
}


f_test_update() {
    VENDOR_URL="$BASE_URL/update"

    ###### prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    head --bytes=64 $BIOTEMPLATE > $BIOTEMPLATE_BR

    if [[ "$TASK" == "update" ]]; then
        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
        f_check -r 200

        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' '$BASE_URL'/add'
        f_check -r 200
    fi

    ###### tests
    TEST_NAME="update 200"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. ID made of digits"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_WITH_CHARSET_1' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_WITH_CHARSET_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. With filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Without filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Without filename parameter with boundary in quotes"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=\"------------------------516695485518814e\"" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Reverse order of headings without filename"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Reverse order of headings with filename 1"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Reverse order of headings with filename 2"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 200. Reverse order of headings with filename 3"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$META_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="update 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:pplication/form-Fata" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="update 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="update 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Broken biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE_BR';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002004' 'Не удалось прочитать биометрический шаблон')"

    TEST_NAME="update 400. BPE-002404 – Не найден биометрический шаблон с заданным идентификатором"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BIGID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002404' 'Не найден биометрический шаблон с заданным идентификатором')"

    TEST_NAME="update 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid template type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=image/png" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="update 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BADTYPE' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="update 400. BPE-00005 – Не удалось прочитать метаданные. No parameters"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="update 400. BPE-00005 – Не удалось прочитать метаданные. Extra comma in metadata"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="update 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. Bad parameter \"template_id\""
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    # TEST_NAME="update 400. BPE-00502. No template data"
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$EMPTY';type=application/octet-stream" -F '$META' --output '$BODY' '$VENDOR_URL
    # f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="update 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No template part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F '$META' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="update 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata body"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="update 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="update 400. BPE-00506 – Недопустимое значение параметра {название параметра}. Invalid template_id parameter value"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_IPV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00506' 'Недопустимое значение параметра.+')"

    ###### cleaning
    if [[ "$TASK" == "update" ]]; then
        TEST_NAME="CLEANING - delete template_id: 722852fdf2ca4900be3707d80243fd70"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200

        TEST_NAME="CLEANING - delete template_id: 1234510050067890"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_2' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200
    fi
}


f_test_delete() {
    VENDOR_URL="$BASE_URL/delete"

    ###### prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    if [[ "$TASK" == "delete" ]]; then
        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
        f_check -r 200

        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' '$BASE_URL'/add'
        f_check -r 200
    fi

    ###### tests
    TEST_NAME='delete 200'
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' '$VENDOR_URL
    f_check -r 200
    
    TEST_NAME='delete 200. ID made of digits'
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200

    TEST_NAME="delete 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:ppplication/gson" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="delete 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="delete 400. BPE-002404 – Не найден биометрический шаблон с заданным идентификатором"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002404' 'Не найден биометрический шаблон с заданным идентификатором')"

    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200

    TEST_NAME="delete 400. BPE-002404 – Не найден биометрический шаблон с заданным идентификатором"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_BIG' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002404' 'Не найден биометрический шаблон с заданным идентификатором')"

    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200

    TEST_NAME="delete 400. BPE-00005 – Не удалось прочитать метаданные. Extra comma in metadata"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="delete 400. BPE-00005 – Не удалось прочитать метаданные. No parameter"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="delete 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. Bad parameter \"template_id\""
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_NOID' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="delete 400. BPE-00506 – Недопустимое значение параметра {название параметра}. Invalid template_id parameter value"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_IPV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00506' 'Недопустимое значение параметра.+')"
}


f_test_match() {
    VENDOR_URL="$BASE_URL/match"

    ###### prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    head --bytes=64 $BIOTEMPLATE > $BIOTEMPLATE_BR
    
    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
    f_check -r 200
    
    TEST_NAME="PREPARE - add biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' '$BASE_URL'/add'
    f_check -r 200

    sleep 5

    ###### tests
    TEST_NAME="match 200"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_WITH_CHARSET_1' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_WITH_CHARSET_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Exponential format of limit"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_NUMBER' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. With threshold 0.0"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_00' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. With threshold 1.0"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_10' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX_1_0} -f "- format double or empty array is expected"

    TEST_NAME="match 200. With filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Without filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Without filename parameter with boundary in quotes"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="template"\r\nContent-Type: application/octet-stream\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=\"------------------------516695485518814e\"" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Reverse order of headings without filename"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Reverse order of headings with filename 1"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Reverse order of headings with filename 2"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 200. Reverse order of headings with filename 3"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: application/octet-stream\r\nContent-Disposition: form-data; name="template"; filename="biotemplate"\r\n\r\n' > tmp/request_body; cat $BIOTEMPLATE >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="match 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:ppplication/form-Fata" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="match 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="match 400. BPE-002004 – Не удалось прочитать биометрический шаблон. Broken biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE_BR';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002004' 'Не удалось прочитать биометрический шаблон')"

    TEST_NAME="match 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid template type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="match 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_BADTYPE' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="match 400. BPE-00005 – Не удалось прочитать метаданные. No parameters"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="match 400. BPE-00005 – Не удалось прочитать метаданные. Extra comma in metadata"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    # TEST_NAME="match 400. BPE-00005. No template"
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$EMPTY';type=application/octet-stream" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    # f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="match 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No limit parameter"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_NOLIM' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="match 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No threshold parameter"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_NOTH' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="match 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No template part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="match 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata body"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F "metadata={};type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="match 400. BPE-00506 – Недопустимое значение параметра {название параметра}. Invalid limit parameter value"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$MMETA_IPV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00506' 'Недопустимое значение параметра.+')"

    ###### cleaning
    if [[ "$TASK" == "match" ]]; then
        TEST_NAME="CLEANING - delete template_id: 722852fdf2ca4900be3707d80243fd70"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200

        TEST_NAME="CLEANING - delete template_id: 1234510050067890"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_2' --output '$BODY' -X POST '$BASE_URL'/delete'
        f_check -r 200
    fi
}


f_test_identify() {
    VENDOR_URL="$BASE_URL/identify"

    ###### prepare
    TEST_NAME="PREPARE - create biotemplate"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @'$SAMPLE_JPG' --output '$BIOTEMPLATE' '$BASE_URL'/extract'
    f_check -r 200

    dd if=/dev/urandom of=$SAMPLE_BR bs=1024 count=4 status=none

    if [[ "$TASK" == "identify" ]]; then
        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META' '$BASE_URL'/add'
        f_check -r 200
        
        TEST_NAME="PREPARE - add biotemplate"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "template=@'$BIOTEMPLATE';type=application/octet-stream" -F '$META_2' '$BASE_URL'/add'
        f_check -r 200
    fi

    sleep 5

    ###### tests
    TEST_NAME="identify 200. JPG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_PNG';type=image/png" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    \cp $SAMPLE_JPG $SAMPLE_JPG_WFE
    TEST_NAME="identify 200. JPG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG_WFE';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"
    rm -f $SAMPLE_JPG_WFE

    \cp $SAMPLE_PNG $SAMPLE_PNG_WFE
    TEST_NAME="identify 200. PNG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_PNG_WFE';type=image/png" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"
    rm -f $SAMPLE_PNG_WFE

    TEST_NAME="identify 200. Big PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$BIG_SAMPLE_PNG';type=image/png" -F '$MMETA_00' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_LSF';type=image/jpeg" -F '$MMETA_00' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_WITH_CHARSET_1' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_WITH_CHARSET_2' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Exponential format of limit"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_NUMBER' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. With threshold 0.0"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_00' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. With threshold 1.0"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_10' --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX_1_0} -f "- format double or empty array is expected"
    
    TEST_NAME="identify 200. With filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="photo"; filename="photo.jpg"\r\nContent-Type: image/jpeg\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Without filename parameter"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="photo"\r\nContent-Type: image/jpeg\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Without filename parameter with big photo"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="photo"\r\nContent-Type: image/png\r\n\r\n' > tmp/request_body; cat $BIG_SAMPLE_PNG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID_2\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Without filename parameter with boundary in quotes"
    echo -ne '--------------------------516695485518814e\r\nContent-Disposition: form-data; name="photo"\r\nContent-Type: image/jpeg\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=\"------------------------516695485518814e\"" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Reverse order of headings without filename"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="photo"\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Reverse order of headings with filename 1"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="photo"; filename="photo.jpg"\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Reverse order of headings with filename 2"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="photo"\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 200. Reverse order of headings with filename 3"
    echo -ne '--------------------------516695485518814e\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="photo"; filename="photo.jpg"\r\n\r\n' > tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--------------------------516695485518814e\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="metadata"\r\n\r\n' >> tmp/request_body; echo -ne "$MMETA_ID\r\n" >> tmp/request_body
    echo -ne '--------------------------516695485518814e--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data; boundary=------------------------516695485518814e" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${MATCH_REGEX} -f "- format double is expected"

    TEST_NAME="identify 400. BPE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:part/fordata" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="identify 400. BPE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA' --output '$BODY' -X GET '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="identify 400. BPE-002003 – Не удалось прочитать биометрический образец. Broken sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_BR';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002003' 'Не удалось прочитать биометрический образец')"

    TEST_NAME="identify 400. BPE-002003 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$EMPTY';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002003' 'Не удалось прочитать биометрический образец')"

    TEST_NAME="identify 400. BPE-002003 – Не удалось прочитать биометрический образец. Sound file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_WAV';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002003' 'Не удалось прочитать биометрический образец')"

    TEST_NAME="identify 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=audio/pcm" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="identify 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_BADTYPE' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="identify 400. BPE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=audio/wav" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="identify 400. BPE-00005 – Не удалось прочитать метаданные. No parameters"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$META_BROKEN' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="identify 400. BPE-00005 – Не удалось прочитать метаданные. Extra comma in metadata"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_BAD' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00005' 'Не удалось прочитать метаданные')"

    TEST_NAME="identify 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No threshold parameter"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_NOTH' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="identify 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No limit parameter"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_NOLIM' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="identify 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No photo part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="identify 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata body"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$META_EMPTY' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="identify 400. BPE-00502 – Запрос не содержит обязательных данных {название данных/параметров}. No metadata part"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00502' 'Запрос не содержит обязательных данных.+')"

    TEST_NAME="identify 400. BPE-00506 – Недопустимое значение параметра {название параметра}. Invalid limit parameter value"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_JPG';type=image/jpeg" -F '$MMETA_IPV' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-00506' 'Недопустимое значение параметра.+')"

    TEST_NAME="identify 400. BPE-003002 – На биометрическом образце отсутствует лицо. No face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_NF';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-003002' 'На биометрическом образце отсутствует лицо')"

    TEST_NAME="identify 400. BPE-003003 – На биометрическом образце присутствует более, чем одно лицо. More than one face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: '$(uuidgen)'" -F "photo=@'$SAMPLE_TF';type=image/jpeg" -F '$MMETA' --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'BPE-003003' 'На биометрическом образце присутствует более, чем одно лицо')"

    ###### prepare
    TEST_NAME="PREPARE - delete template_id: 722852fdf2ca4900be3707d80243fd70"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200
    
    TEST_NAME="PREPARE - delete template_id: 1234510050067890"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type: application/json" -H "X-Request-ID: '$(uuidgen)'" --data '$RDATA_2' --output '$BODY' -X POST '$BASE_URL'/delete'
    f_check -r 200
}


f_print_usage() {
echo "Usage: $0 [OPTIONS] URL TIMEOUT

OPTIONS:
    -t  string      Set test method: all (default), health, extract, add, update, delete, match, identify
    -p  string      Prefix
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
            BASE_URL="http://$URL/$R/$P"
        else
            BASE_URL="http://$URL/$R"
        fi

        VENDOR_URL="$BASE_URL/health"
        BODY="tmp/responce_body"
        TEST_NAME="health 200"
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
                echo; echo; echo "------------ Begin: f_test_add -------------"
                f_test_add
                echo; echo; echo "------------ Begin: f_test_update -------------"
                f_test_update
                echo; echo; echo "------------ Begin: f_test_delete -------------"
                f_test_delete
                echo; echo; echo "------------ Begin: f_test_match -------------"
                f_test_match
                echo; echo; echo "------------ Begin: f_test_identify -------------"
                f_test_identify
            ;;
            health ) f_test_health;;
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