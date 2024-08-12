#!/bin/bash

# include functions
source include/f_checks.sh

f_test_active_liveness_video() {
    TYPE=$1
    MNEMONIC=$2
    ACTIONS=$3
    BODY="tmp/responce_body"
    
    TURN_RIGHT_VERTICAL_SAMPLE_MOV="resources/samples/vert_turn_right_video"
    TURN_RIGHT_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_turn_right_video"
    TURN_LEFT_VERTICAL_SAMPLE_MOV="resources/samples/vert_turn_left_video"
    TURN_LEFT_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_turn_left_video"
    TURN_UP_VERTICAL_SAMPLE_MOV="resources/samples/vert_turn_up_video"
    TURN_UP_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_turn_up_video"
    TURN_DOWN_VERTICAL_SAMPLE_MOV="resources/samples/vert_turn_down_video"
    TURN_DOWN_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_turn_down_video"
    SMILE_VERTICAL_SAMPLE_MOV="resources/samples/vert_smile_video"
    SMILE_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_smile_video"
    BLINK_VERTICAL_SAMPLE_MOV="resources/samples/vert_blink_video"
    BLINK_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_blink_video"
    DISTORTION_VERTICAL_SAMPLE_MOV="resources/samples/vert_distortion_video"
    DISTORTION_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_distortion_video"
    RAISE_EYEBROW_VERTICAL_SAMPLE_MOV="resources/samples/vert_raise_eyebrow_video"
    RAISE_EYEBROW_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_raise_eyebrow_video"

    NUMBERS_DIGITS_VERTICAL_SAMPLE_MOV="resources/samples/vert_numbers_digits_video"
    NUMBERS_DIGITS_HORIZONTAL_SAMPLE_MOV="resources/samples/horizon_numbers_digits_video"
    
    # BIG_SAMPLE_MOV="resources/samples/___________________"
    VERTICAL_SAMPLE_MOV_WFE="resources/samples/vert_blink_video.mov"
    HORIZONTAL_SAMPLE_MOV_WFE="resources/samples/horizon_blink_video.mov"
    VERTICAL_SAMPLE_LSF="resources/samples/vert_little_second_face_video"
    HORIZONTAL_SAMPLE_LSF="resources/samples/horizon_little_second_face_video"

    EMPTY="resources/samples/empty"
    SAMPLE_WAV="resources/samples/sound.wav"
    SAMPLE_JPG="resources/samples/photo_shumskiy.jpg"
    SAMPLE_DOG_MOV="resources/samples/dog_video"
    SAMPLE_NF_MOV="resources/samples/no_face_video"
    SAMPLE_TF_MOV="resources/samples/two_face_video"

    META_TURN_RIGHT=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"TURN_RIGHT","duration":7000,"message":"Пожалуйста, посмотрите направо"}]};type=application/json'\'
    META_TURN_LEFT=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"TURN_LEFT","duration":6000,"message":"Пожалуйста, посмотрите налево"}]};type=application/json'\'
    META_TURN_UP=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"TURN_UP","duration":4000,"message":"Пожалуйста, посмотрите вверх"}]};type=application/json'\'
    META_TURN_DOWN=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"TURN_DOWN","duration":3000,"message":"Пожалуйста, посмотрите вниз"}]};type=application/json'\'
    META_SMILE=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"SMILE","duration":4000,"message":"Пожалуйста, улыбнитесь"}]};type=application/json'\'
    META_BLINK=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"BLINK","duration":3000,"message":"Пожалуйста, моргните"}]};type=application/json'\'
    META_DISTORTION=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"DISTORTION","duration":6000,"message":"Пожалуйста, отдалите телефон и не спеша приближайте его к лицу"}]};type=application/json'\'
    META_RAISE_EYEBROW=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"RAISE_EYEBROW","duration":3000,"message":"Пожалуйста, поднимите брови"}]};type=application/json'\'
    TEXT_META_1=\''metadata={"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","duration":5000,"message":"Произнесите цифры:","text":"ноль два один восемь семь"}]};type=application/json'\'
    TEXT_META_2=\''metadata={"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","duration":5000,"message":"Произнесите цифры:","text":"шесть четыре один ноль два"}]};type=application/json'\'

    if [ "$MNEMONIC" == "move" ]; then
        if [ "$ACTIONS" == "all" ]; then
            MOVE_META="$META_BLINK"
        else
            FIRST_MOVE_ACTION=${ACTIONS:0:1}

            case "$FIRST_MOVE_ACTION" in
                "1") MOVE_META="$META_TURN_RIGHT";;
                "2") MOVE_META="$META_TURN_LEFT";;
                "3") MOVE_META="$META_TURN_UP";;
                "4") MOVE_META="$META_TURN_DOWN";;
                "5") MOVE_META="$META_SMILE";;
                "6") MOVE_META="$META_BLINK";;
                "7") MOVE_META="$META_DISTORTION";;
                "8") MOVE_META="$META_RAISE_EYEBROW";;
            esac
        fi
    fi

    # добавляем к парте с метаданными часть с явным указанием кодировки
    MOVE_META_WITH_CHARSET_1=${MOVE_META::-1}';charset=UTF-8'\'
    MOVE_META_WITH_CHARSET_2=${MOVE_META::-1}'; charset=UTF-8'\'
    TEXT_META_WITH_CHARSET_1=${TEXT_META_1::-1}';charset=UTF-8'\'
    TEXT_META_WITH_CHARSET_2=${TEXT_META_1::-1}';charset=UTF-8'\'

    # оставляем только метаданные без составных частей HTTP-запроса
    MOVE_META_WF=${MOVE_META:10:-23}
    TEXT_META_WF=${TEXT_META_1:10:-23}
    #TEXT_META_WF='{"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","duration":5000,"message":"Произнесите цифры:","text":"ноль два один восемь семь"}]}'

    MOVE_META_WM=\''metadata={"actions":[{"type":"BLINK","duration":3000,"message":"Пожалуйста, моргните"}]};type=application/json'\'
    TEXT_META_WM=\''metadata={"actions":[{"type":"numbers-digits","duration":5000,"message":"Произнесите цифры:","text":"ноль два один восемь семь"}]};type=application/json'\'
    MOVE_META_WA=\''metadata={"mnemonic":"move-instructions"};type=application/json'\'
    TEXT_META_WA=\''metadata={"mnemonic":"text-instructions"};type=application/json'\'
    MOVE_META_WT=\''metadata={"mnemonic":"move-instructions","actions":[{"duration":3000,"message":"Пожалуйста, моргните"}]};type=application/json'\'
    TEXT_META_WT=\''metadata={"mnemonic":"text-instructions","actions":[{"duration":5000,"message":"Произнесите цифры:","text":"ноль два один восемь семь"}]};type=application/json'\'
    MOVE_META_WD=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"BLINK","message":"Пожалуйста, моргните"}]};type=application/json'\'
    TEXT_META_WD=\''metadata={"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","message":"Произнесите цифры:","text":"ноль два один восемь семь"}]};type=application/json'\'
    MOVE_META_WMSG=\''metadata={"mnemonic":"move-instructions","actions":[{"type":"BLINK","duration":3000}]};type=application/json'\'
    TEXT_META_WMSG=\''metadata={"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","duration":5000,"text":"ноль два один восемь семь"}]};type=application/json'\'
    META_WTEXT=\''metadata={"mnemonic":"text-instructions","actions":[{"type":"numbers-digits","duration":5000,"message":"Произнесите цифры:"}]};type=application/json'\'

    [[ "$MNEMONIC" == "move" ]] && META="$MOVE_META" || META="$TEXT_META_1"
    [[ "$MNEMONIC" == "move" ]] && META_CHARSET_1="$MOVE_META_WITH_CHARSET_1" || META_CHARSET_1="$TEXT_META_WITH_CHARSET_1"
    [[ "$MNEMONIC" == "move" ]] && META_CHARSET_2="$MOVE_META_WITH_CHARSET_2" || META_CHARSET_2="$TEXT_META_WITH_CHARSET_2"
    [[ "$MNEMONIC" == "move" ]] && VERTICAL_SAMPLE_MOV="$BLINK_VERTICAL_SAMPLE_MOV" || VERTICAL_SAMPLE_MOV="$NUMBERS_DIGITS_VERTICAL_SAMPLE_MOV"
    [[ "$MNEMONIC" == "move" ]] && HORIZONTAL_SAMPLE_MOV="$BLINK_HORIZONTAL_SAMPLE_MOV" || HORIZONTAL_SAMPLE_MOV="$NUMBERS_DIGITS_HORIZONTAL_SAMPLE_MOV"
    [[ "$MNEMONIC" == "move" ]] && META_WF="$MOVE_META_WF" || META_WF="$TEXT_META_WF"
    [[ "$MNEMONIC" == "move" ]] && META_WM="$MOVE_META_WM" || META_WM="$TEXT_META_WM"
    [[ "$MNEMONIC" == "move" ]] && META_WA="$MOVE_META_WA" || META_WA="$TEXT_META_WA"
    [[ "$MNEMONIC" == "move" ]] && META_WT="$MOVE_META_WT" || META_WT="$TEXT_META_WT"
    [[ "$MNEMONIC" == "move" ]] && META_WD="$MOVE_META_WD" || META_WD="$TEXT_META_WD"
    [[ "$MNEMONIC" == "move" ]] && META_WMSG="$MOVE_META_WMSG" || META_WMSG="$TEXT_META_WMSG"

    VENDOR_URL="$BASE_URL/detect"


    if [ "$MNEMONIC" == "move" ]; then
        if [[ "$ACTIONS" =~ 1  || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with TURN_RIGHT type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_RIGHT' -F "bio_sample=@'$TURN_RIGHT_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with TURN_RIGHT type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_RIGHT' -F "bio_sample=@'$TURN_RIGHT_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 2 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with TURN_LEFT type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_LEFT' -F "bio_sample=@'$TURN_LEFT_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with TURN_LEFT type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_LEFT' -F "bio_sample=@'$TURN_LEFT_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 3 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with TURN_UP type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_UP' -F "bio_sample=@'$TURN_UP_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with TURN_UP type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_UP' -F "bio_sample=@'$TURN_UP_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 4 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with TURN_DOWN type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_DOWN' -F "bio_sample=@'$TURN_DOWN_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with TURN_DOWN type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_TURN_DOWN' -F "bio_sample=@'$TURN_DOWN_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 5 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with SMILE type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_SMILE' -F "bio_sample=@'$SMILE_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with SMILE type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_SMILE' -F "bio_sample=@'$SMILE_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 6 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with BLINK type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_BLINK' -F "bio_sample=@'$BLINK_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with BLINK type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_BLINK' -F "bio_sample=@'$BLINK_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 7 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with DISTORTION type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_DISTORTION' -F "bio_sample=@'$DISTORTION_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with DISTORTION type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_DISTORTION' -F "bio_sample=@'$DISTORTION_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

        if [[ "$ACTIONS" =~ 8 || "$ACTIONS" == "all" ]]; then
            TEST_NAME="detect 200. Vertical MOV video with RAISE_EYEBROW type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_RAISE_EYEBROW' -F "bio_sample=@'$RAISE_EYEBROW_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

            TEST_NAME="detect 200. Horizontal MOV video with RAISE_EYEBROW type"
            REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_RAISE_EYEBROW' -F "bio_sample=@'$RAISE_EYEBROW_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
            f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
        fi

    elif [ "$MNEMONIC" == "text" ]; then
        TEST_NAME="detect 200. Vertical MOV video with numbers-digits type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$TEXT_META_1' -F "bio_sample=@'$NUMBERS_DIGITS_VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
        f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

        TEST_NAME="detect 200. Horizontal MOV video with numbers-digits type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$TEXT_META_2' -F "bio_sample=@'$NUMBERS_DIGITS_HORIZONTAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
        f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    fi

    # TEST_NAME="detect 200. Big video"
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$BIG_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    # f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    \cp $VERTICAL_SAMPLE_MOV $VERTICAL_SAMPLE_MOV_WFE
    TEST_NAME="detect 200. Vertical video with filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV_WFE';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    rm -f $VERTICAL_SAMPLE_MOV_WFE

    \cp $HORIZONTAL_SAMPLE_MOV $HORIZONTAL_SAMPLE_MOV_WFE
    TEST_NAME="detect 200. Horizontal video with filename extension"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$HORIZONTAL_SAMPLE_MOV_WFE';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    rm -f $HORIZONTAL_SAMPLE_MOV_WFE

    TEST_NAME="detect 200. Vertical with little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_LSF';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Horizontal with little second face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$HORIZONTAL_SAMPLE_LSF';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_CHARSET_1' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. With charset=UTF-8"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META_CHARSET_2' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    # TEST_NAME="detect 200. Without filename parameter with big video"
    # echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    # echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $BIG_SAMPLE_MOV >> tmp/request_body
    # echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    # REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    # f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Without filename parameter with boundary in quotes"
    echo -ne '--72468\r\nContent-Disposition: form-data; name="metadata"\r\nContent-Type: application/json\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Disposition: form-data; name="bio_sample"\r\nContent-Type: video/mov\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=\"72468\"" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings without filename"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
    
    TEST_NAME="detect 200. Reverse order of headings with filename 1"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"; filename="vertical_active_video"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 2"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta.json"\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"

    TEST_NAME="detect 200. Reverse order of headings with filename 3"
    echo -ne '--72468\r\nContent-Type: application/json\r\nContent-Disposition: form-data; name="metadata"; filename="meta.json"\r\n\r\n' > tmp/request_body; echo -ne "$META_WF" >> tmp/request_body
    echo -ne '\r\n--72468\r\nContent-Type: video/mov\r\nContent-Disposition: form-data; name="bio_sample"; filename="vertical_active_video"\r\n\r\n' >> tmp/request_body; cat $VERTICAL_SAMPLE_MOV >> tmp/request_body
    echo -ne '\r\n--72468--\r\n' >> tmp/request_body
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @tmp/request_body --output '$BODY' '$VENDOR_URL
    f_check -r 200 -m "[0-1].[0-9]" -f "- Score format double is expected"
  
    TEST_NAME="detect 400. LDE-002001 – Неверный Content-Type HTTP-запроса. Wrong content-type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:application/json" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002001"

    TEST_NAME="detect 400. LDE-002002 – Неверный метод HTTP-запроса. Invalid http method"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" -X GET --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002002"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Empty file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$EMPTY';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Sound file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$SAMPLE_WAV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002004 – Не удалось прочитать биометрический образец. Photo file"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$SAMPLE_JPG';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002004"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid metadata type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '\'metadata="$META_WF"';type=video/mov'\'' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=application/json" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-002005"

    if [ "$TYPE" == "a_video" ] || [ "$TYPE" == "p_video+a_video" ]; then
        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=audio/wav" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-002005"

        TEST_NAME="detect 400. LDE-002005 – Неверный Content-Type части multiparted HTTP-запроса. Invalid sample type"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=image/png" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-002005"
    fi

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. Dog video"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$SAMPLE_DOG_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003002"

    TEST_NAME="detect 400. LDE-003002 – На биометрическом образце отсутствует лицо. No face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$SAMPLE_NF_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003002"

    TEST_NAME="detect 400. LDE-003003 – На биометрическом образце присутствует более, чем одно лицо. More than one face"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F '$META' -F "bio_sample=@'$SAMPLE_TF_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003003"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without mnemonic"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WM' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WA' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.type"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WT' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.duration"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WD' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"

    TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.message"
    REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WMSG' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
    f_check -r 400 -m "LDE-003004"
    
    if [ "$MNEMONIC" == "text" ]; then
        TEST_NAME="detect 400. LDE-003004 – Не удалось прочитать metadata. Meta without action.text"
        REQUEST='curl -m '$TIMEOUT' -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F '$META_WTEXT' -F "bio_sample=@'$VERTICAL_SAMPLE_MOV';type=video/mov" --output '$BODY' '$VENDOR_URL
        f_check -r 400 -m "LDE-003004"
    fi
}
