#!/usr/bin/env bash

echo Checking the status of the biometric processor
RESULT=$(curl http://${1}/liveness/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "Result - Good. Biometric processor is working correctly"
else
echo "Result - Bad. Biometric processor does not work correctly"
fi
echo ;


echo Positive test 1. detect photo.jpeg
RESULT_H1=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_pass http://${1}/liveness/detect)
echo HTTP status: $RESULT_H1
PLM=`cat trash/res_pass`
echo Result: $PLM
if [ "$RESULT_H1" == "200" ]; then
        if grep -q "score" trash/res_pass; then
                echo "Result - Good"
        else
        echo "result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Positive test 2. detect photo.png
RESULT_H2=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.png;type=image/png" --output trash/res_pass2 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H2
PLN=`cat trash/res_pass2`
echo Result: $PLN
if [ "$RESULT_H2" == "200" ]; then
        if grep -q "score" trash/res_pass; then
                echo "Result - Good"
        else
        echo "result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 1. Request with incorrect HTTP method
RESULT_H3=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.png;type=image/png" --output trash/res_get_req -X GET http://${1}/liveness/detect)
echo HTTP status: $RESULT_H3
PLT=`cat trash/res_get_req`
echo Result: $PLT
if [ "$RESULT_H3" == "400" ]; then
        if [[ "$PLT" =~ "LDE-002002" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 2. Request with empty bio_sample
RESULT_H4=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/empty.jpg;type=image/jpeg" --output trash/res_empty -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H4
PLR=`cat trash/res_empty`
echo Result: $PLR
if [ "$RESULT_H4" == "400" ]; then
        if [[ "$PLR" =~ "LDE-002004" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 3. Incorrect Content-Type
RESULT_H12=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_ct2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H12
PLE=`cat trash/res_ct2`
echo Result: $PLE
if [ "$RESULT_H12" == "400" ]; then
        if [[ "$PLE" =~ "LDE-002001" ]]; then
                echo "Result - Good"
        else
        echo "result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 4. Incorrect Content-Type part of multipart
RESULT_H20=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=image/jpeg" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_ctm1 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H20
PLX=`cat trash/res_ctm1`
echo Result: $PLX
if [ "$RESULT_H20" == "400" ]; then
        if [[ "$PLX" =~ "LDE-002005" ]]; then
                echo "Result - Good"
        else
        echo "result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 5. Incorrect Content-Type part of multipart
RESULT_H21=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=application/json" --output trash/res_ctm2 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H21
Q=`cat trash/res_ctm2`
echo Result: $Q
if [ "$RESULT_H21" == "400" ]; then
        if [[ "$Q" =~ "LDE-002005" ]]; then
                echo "Result - Good"
        else
        echo "result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;



echo Negative test 6. Request with sound
RESULT_H8=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/sound.wav;type=audio/wav" --output trash/res_sound1 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H8
PLQ=`cat trash/res_sound1`
echo Result: $PLQ
if [ "$RESULT_H8" == "400" ]; then
        if [[ "$PLQ" =~ "LDE-002005" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;



echo Negative test 7. Request with sound
RESULT_H9=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/sound.wav;type=image/jpeg" --output trash/res_sound2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H9
PLZ=`cat trash/res_sound2`
echo Result: $PLZ
if [ "$RESULT_H9" == "400" ]; then
        if [[ "$PLZ" =~ "LDE-002004" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 8. Request with video
RESULT_H10=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/video.webm;type=image/jpeg" --output trash/res_vid1 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H10
PLB=`cat trash/res_vid1`
echo Result: $PLB
if [ "$RESULT_H10" == "400" ]; then
        if [[ "$PLB" =~ "LDE-002004" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 9. Request with video
RESULT_H11=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/video.webm;type=video/webm" --output trash/res_vid2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H11
PLJ=`cat trash/res_vid2`
echo Result: $PLJ
if [ "$RESULT_H11" == "400" ]; then
        if [[ "$PLJ" =~ "LDE-002005" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 10. Request with meta without mnemonic
RESULT_H12=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta_without_mnemonic.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_meta_without_mnemonic http://${1}/liveness/detect)
echo HTTP status: $RESULT_H12
MWM=`cat trash/res_meta_without_mnemonic`
echo Result: $MWM
if [ "$RESULT_H12" == "400" ]; then
	if [[ "MWM" =~ "LDE-002003" ]]; then
		echo "Result - Good"
	else
	echo "HTTP status good. Result bad"
	fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 11. Request with meta without action
RESULT_H13=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta_without_action.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_meta_without_action http://${1}/liveness/detect)
echo HTTP status: $RESULT_H13
MWA=`cat trash/res_meta_without_action`
echo Result: $MWA
if [ "$RESULT_H13" == "400" ]; then
        if [[ "MWA" =~ "LDE-002003" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 12. Request with meta without action.type
RESULT_H14=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta_without_type.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_meta_without_action_type http://${1}/liveness/detect)
echo HTTP status: $RESULT_H14
MWAT=`cat trash/res_meta_without_action_type`
echo Result: $MWAT
if [ "$RESULT_H14" == "400" ]; then
        if [[ "MWAT" =~ "LDE-002003" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 13. Request with meta without action.duration
RESULT_H15=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta_without_duration.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_meta_without_action_duration http://${1}/liveness/detect)
echo HTTP status: $RESULT_H15
MWAD=`cat trash/res_meta_without_action_duration`
echo Result: $MWAD
if [ "$RESULT_H15" == "400" ]; then
        if [[ "MWAD" =~ "LDE-002003" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;


echo Negative test 14. Request with meta without action.message
RESULT_H16=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta_without_message.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output trash/res_meta_without_action_message http://${1}/liveness/detect)
echo HTTP status: $RESULT_H16
MWAM=`cat trash/res_meta_without_action_duration`
echo Result: $MWAM
if [ "$RESULT_H16" == "400" ]; then
        if [[ "MWAM" =~ "LDE-002003" ]]; then
                echo "Result - Good"
        else
        echo "HTTP status good. Result bad"
        fi
else
echo "HTTP status bad"
fi
echo ;
