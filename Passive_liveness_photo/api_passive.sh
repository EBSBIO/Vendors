#!/usr/bin/env bash

echo health.200
RESULT=$(curl http://${1}/liveness/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "OK"
else
echo "FAIL"
fi
echo ;


echo detect.200.JPG
RESULT_H1=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/res_pass http://${1}/liveness/detect)
echo HTTP status: $RESULT_H1
PLM=`cat Resources/trash/res_pass`
echo Result: $PLM
if [ "$RESULT_H1" == "200" ]; then
        if grep -q "score" Resources/trash/res_pass; then
                echo "OK"
        else
        echo "FAIL (HTTP 200, but no score field in response body)"
        fi
else
echo "FAIL"
fi
echo ;


echo detect.200.PNG
RESULT_H2=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.png;type=image/png" --output Resources/trash/res_pass2 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H2
PLM=`cat Resources/trash/res_pass2`
echo Result: $PLM
if [ "$RESULT_H2" == "200" ]; then
        if grep -q "score" Resources/trash/res_pass; then
                echo "OK"
        else
        echo "FAIL (HTTP 200, but no score field in response body)"
        fi
else
echo "FAIL"
fi
echo ;


echo detect.400.LDE-002002
RESULT_H3=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.png;type=image/png" --output Resources/trash/res_get_req -X GET http://${1}/liveness/detect)
echo HTTP status: $RESULT_H3
PLM=`cat Resources/trash/res_get_req`
echo Result: $PLM
if [ "$RESULT_H3" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002002" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002002 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002004.empty_sample
RESULT_H4=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/empty.jpg;type=image/jpeg" --output Resources/trash/res_empty -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H4
PLM=`cat Resources/trash/res_empty`
echo Result: $PLM
if [ "$RESULT_H4" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002004" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002004 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002001.wrong_content-type
RESULT_H12=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/res_ct2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H12
PLM=`cat Resources/trash/res_ct2`
echo Result: $PLM
if [ "$RESULT_H12" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002001" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002001 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002005.wrong_content-type_metadata
RESULT_H20=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=image/jpeg" -F "bio_sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/res_ctm1 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H20
PLM=`cat Resources/trash/res_ctm1`
echo Result: $PLM
if [ "$RESULT_H20" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002005" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002005 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002005.wrong_content-type_sample
RESULT_H21=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/photo.jpg;type=application/json" --output Resources/trash/res_ctm2 http://${1}/liveness/detect)
echo HTTP status: $RESULT_H21
Q=`cat Resources/trash/res_ctm2`
echo Result: $PLM
if [ "$RESULT_H21" == "400" ]; then
        if [[ "$Q" =~ "LDE-002005" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002005 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;



echo detect.400.LDE-002005.sound
RESULT_H8=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/sound.wav;type=audio/wav" --output Resources/trash/res_sound1 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H8
PLM=`cat Resources/trash/res_sound1`
echo Result: $PLM
if [ "$RESULT_H8" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002005" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002005 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;



echo detect.400.LDE-002004.sound
RESULT_H9=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/sound.wav;type=image/jpeg" --output Resources/trash/res_sound2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H9
PLM=`cat Resources/trash/res_sound2`
echo Result: $PLM
if [ "$RESULT_H9" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002004" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002004 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002004.video
RESULT_H10=$(curl -s -w "%{http_code}" -H "Expect:" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/video.webm;type=image/jpeg" --output Resources/trash/res_vid1 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H10
PLM=`cat Resources/trash/res_vid1`
echo Result: $PLM
if [ "$RESULT_H10" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002004" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002004 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;


echo detect.400.LDE-002005.video
RESULT_H11=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -F "metadata=@Resources/meta.json;type=application/json" -F "bio_sample=@Resources/video.webm;type=video/webm" --output Resources/trash/res_vid2 -X POST http://${1}/liveness/detect)
echo HTTP status: $RESULT_H11
PLM=`cat Resources/trash/res_vid2`
echo Result: $PLM
if [ "$RESULT_H11" == "400" ]; then
        if [[ "$PLM" =~ "LDE-002005" ]]; then
                echo "OK"
        else
        echo "FAIL (LDE-002004 is expected)"
        fi
else
echo "FAIL (HTTP 400 is expected)"
fi
echo ;
