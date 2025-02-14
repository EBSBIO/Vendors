#!/bin/bash
##########################
#                        #
# Author: kflirik        #
#                        #
##########################

# include functions
source include/f_checks.sh

f_test_passive_liveness_video() {
    TYPE=$1
    PHOTO_SCORE_REGEX=$2

    BODY="tmp/responce_body"

    VERTICAL_SAMPLE_MOV="resources/samples/vert_passive_video"
    HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_passive_video"
    VERTICAL_SAMPLE_MOV_WV="resources/samples/vert_numbers_digits_video"
    HORIZONTAL_SAMPLE_MOV_WV="resources/samples/horizon_numbers_digits_video"
    VERTICAL_SAMPLE_MOV_WFE="resources/samples/vert_passive_video.mov"
    HORIZONTAL_SAMPLE_MOV_WFE="resources/samples/horizon_passive_video.mov"
    # BIG_SAMPLE_MOV="resources/samples/___________________"
    VERTICAL_SAMPLE_LSF="resources/samples/vert_little_second_face_video"
    HORIZONTAL_SAMPLE_LSF="resources/samples/horizon_little_second_face_video"

    EMPTY="resources/samples/empty"
    SAMPLE_WAV="resources/samples/sound.wav"
    SAMPLE_JPG="resources/samples/photo_shumskiy.jpg"
    SAMPLE_DOG_MOV="resources/samples/dog_video"
    SAMPLE_NF_MOV="resources/samples/no_face_video"
    SAMPLE_TF_MOV="resources/samples/two_face_video"

    META="resources/metadata/meta_lv_v_p.json"
    META_WM="resources/metadata/meta_without_mnemonic_lv_v_p.json"
    META_WA="resources/metadata/meta_without_action.json"
    META_WT="resources/metadata/meta_without_type_lv_v_p.json"
    META_WD="resources/metadata/meta_without_duration.json"
    META_WMSG="resources/metadata/meta_without_message_lv_v_p.json"
    
    VENDOR_URL="$BASE_URL/detect"


    TEST_NAME="detect 200. Vertical video"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Horizontal video"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Vertical video with voice"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV_WV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Horizontal video with voice"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$HORIZONTAL_SAMPLE_MOV_WV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    \cp $VERTICAL_SAMPLE_MOV $VERTICAL_SAMPLE_MOV_WFE
    TEST_NAME="detect 200. Vertical video with filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV_WFE';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"
    rm -f $VERTICAL_SAMPLE_MOV_WFE

    \cp $HORIZONTAL_SAMPLE_MOV $HORIZONTAL_SAMPLE_MOV_WFE
    TEST_NAME="detect 200. Horizontal video with filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$HORIZONTAL_SAMPLE_MOV_WFE';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"
    rm -f $HORIZONTAL_SAMPLE_MOV_WFE

    # TEST_NAME="detect 200. Big video"
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$BIG_SAMPLE';type=video/mov" --output '$BODY' '$VENDOR_URL
    # f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Vertical with little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_LSF';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Horizontal with little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$HORIZONTAL_SAMPLE_LSF';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json;charset=UTF-8" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json; charset=UTF-8" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    # TEST_NAME="detect 200. Without filename parameter with big video"
    # echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    # echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $BIG_SAMPLE >> tmp/request_body
    # echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    # f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter with boundary in quotes"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=\"72468\"" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings without filename"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 1"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"; filename="vert_passive_video"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 2"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta_lv_v_p.json"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"
        
    TEST_NAME="detect 200. Reverse order of headings with filename 3"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta_lv_v_p.json"\r\n\r\n' > tmp/request_body; cat $META >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"; filename="vert_passive_video"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m ${PHOTO_SCORE_REGEX} -f "- Score format double is expected"

    TEST_NAME="detect 400. LDE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002001' 'Неверный Content-Type HTTP-запроса')"

    TEST_NAME="detect 400. LDE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002002' 'Неверный метод HTTP-запроса')"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$EMPTY';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002004' 'Не удалось прочитать биометрический образец.*')"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Sound file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_WAV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002004' 'Не удалось прочитать биометрический образец.*')"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Photo file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_JPG';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002004' 'Не удалось прочитать биометрический образец.*')"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=video/mov" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

    if [ "$TYPE" == "p_video" ] || [ "$TYPE" == "p_video+a_video" ]; then
        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=audio/wav" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "$(f_err_regex 'LDE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"

        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=image/png" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "$(f_err_regex 'LDE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"
        
    elif [ "$TYPE" == "photo+p_video" ]; then
        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=audio/wav" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "$(f_err_regex 'LDE-002005' 'Неверный Content-Type части multiparted HTTP-запроса')"
    fi

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. Dog video"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_DOG_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003002' 'На биометрическом образце отсутствует лицо')"

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. No face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_NF_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003002' 'На биометрическом образце отсутствует лицо')"

    TEST_NAME="detect 400. LDE-003003 – На биометрическом образце присутствует более, чем одно лицо. More than one face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@'$META';type=application/json" -F "bio_sample=@'$SAMPLE_TF_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003003' 'На биометрическом образце присутствует более, чем одно лицо')"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without mnemonic"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WM';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003004' 'Не удалось прочитать metadata')"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WA';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003004' 'Не удалось прочитать metadata')"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WT';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003004' 'Не удалось прочитать metadata')"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.duration"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WD';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003004' 'Не удалось прочитать metadata')"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.message"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@'$META_WMSG';type=application/json" -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "$(f_err_regex 'LDE-003004' 'Не удалось прочитать metadata')"
}
