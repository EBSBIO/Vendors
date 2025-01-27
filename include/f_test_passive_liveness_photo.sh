#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

f_test_passive_liveness_photo() {
    TYPE=$1
    PHOTO_SCORE_REGEX=$2

    BODY="tmp/responce_body"
    
    SAMPLE_JPG="resources/samples/photo_shumskiy.jpg"
    SAMPLE_PNG="resources/samples/photo.png"
    SAMPLE_JPG_WFE="resources/samples/jpeg_photo_wfe"
    SAMPLE_PNG_WFE="resources/samples/png_photo_wfe"
    BIG_SAMPLE_PNG="resources/samples/big.png"
    SAMPLE_LSF="resources/samples/little_second_face.jpg"

    EMPTY="resources/samples/empty"
    SAMPLE_WAV="resources/samples/sound.wav"
    VERTICAL_SAMPLE_MOV="resources/samples/vert_passive_video"
    SAMPLE_CAT_JPG="resources/samples/cat.jpg"
    SAMPLE_NF="resources/samples/no_face.jpg"
    SAMPLE_TF="resources/samples/two_face.jpg"

    META="resources/metadata/meta.json"
    META_WM="resources/metadata/meta_without_mnemonic.json"
    META_WA="resources/metadata/meta_without_action.json"
    META_WT="resources/metadata/meta_without_type.json"
    META_WD="resources/metadata/meta_without_duration.json"
    META_WMSG="resources/metadata/meta_without_message.json"
        
    VENDOR_URL="$BASE_URL/detect"


    TEST_NAME="detect 200. JPG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_PNG';type=image/png" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    \cp $SAMPLE_JPG $SAMPLE_JPG_WFE
    TEST_NAME="detect 200. JPG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG_WFE';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"
    rm -f $SAMPLE_JPG_WFE

    \cp $SAMPLE_PNG $SAMPLE_PNG_WFE
    TEST_NAME="detect 200. PNG sample without filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_PNG_WFE';type=image/png" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"
    rm -f $SAMPLE_PNG_WFE

    TEST_NAME="detect 200. Big PNG sample"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$BIG_SAMPLE_PNG';type=image/png" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_LSF';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json;charset=UTF-8" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json; charset=UTF-8" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: image/jpeg\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter with big photo"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: image/png\r\n\r\n' >> tmp/request_body; cat $BIG_SAMPLE_PNG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter with boundary in quotes"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: image/jpeg\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=\"72468\"" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings without filename"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 1"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="bio_sample"; filename="photo_shumskiy.jpg"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 2"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta.json"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 3"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta.json"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: image/jpeg\r\nContent-Disposition: form-data; name="bio_sample"; filename="photo_shumskiy.jpg"\r\n\r\n' >> tmp/request_body; cat $SAMPLE_JPG >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 400. LDE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002001"

    TEST_NAME="detect 400. LDE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002002"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$EMPTY';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Sound file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Video file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=image/jpeg" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    if [ "$TYPE" == "photo" ]; then
        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=audio/wav" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-002005"

        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=video/mov" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-002005"

    elif [ "$TYPE" == "photo+p_video" ]; then
        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=audio/wav" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-002005"
    fi

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. Cat photo"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_CAT_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003002"

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. No face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_NF';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003002"

    TEST_NAME="detect 400. LDE-003003 – На биометрическом образце присутствует более, чем одно лицо. More than one face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_TF';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003003"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without mnemonic"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WM';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WA';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WT';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.duration"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WD';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.message"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WMSG';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=image/jpeg" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"
}
