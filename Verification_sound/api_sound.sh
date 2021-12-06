#!/usr/bin/env bash

echo Checking the status of the biometric processor
RESULT=$(curl http://${1}/pattern/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "Result - Good. Biometric processor is working correctly"
else
echo "Result - Bad. Biometric processor does not work correctly"
fi
echo ;


#echo Positive extraction test 2. Extract wav sound
#RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @sound.wav --output bio_template http://${1}/pattern/extract)
#echo HTTP status: $RESULT
#PLM=`du -b bio_template`
#echo Size and name of template: $PLM 
#if [ "$RESULT" == "200" ]; then
#	if [[ "$PLM" == *[1-9]* ]]; then
#		echo "Result - Good"
#	else
#	echo "HTTP status good, but template empty"
#	fi
#else
#echo "Result - Bad. Biometric template was not created. Successful template extraction expected"
#fi
#echo ;


echo Positive extraction test 1. Extract pcm sound
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @Resources/sound.wav --output Resources/template/bio_template_a http://${1}/pattern/extract)
echo HTTP status: $RESULT
PLO=`du -b Resources/template/bio_template_a`
echo Size and name of template: $PLO
if [ "$RESULT" == "200" ]; then
	if [[ "$PLO" == *[1-9]* ]]; then
		echo "Result - Good"
	else
	echo "HTTP status good, but template empty"
	fi
else
echo "Result - Bad. Biometric template was not created. Successful template extraction expected"
fi
echo ;


echo Negative extraction test 1. Attempting to extract a template from a file of zero size
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @Resources/empty.wav --output Resources/trash/bio_template_q http://${1}/pattern/extract)
echo HTTP status: $RESULT
PP=`cat Resources/trash/bio_template_q`
echo json status: $PP
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$PP" =~ "BPE-002003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-002003"
fi
echo ;


echo Negative extraction test 2. Attempting to extract a template from a file without voice
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @Resources/sound_without_voice.wav --output Resources/trash/bio_template_b http://${1}/pattern/extract)
echo HTTP status: $RESULT
II=`cat Resources/trash/bio_template_b`
echo json status: $II
if [[ "$RESULT" =~ "400" ]]; 
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$II" =~ "BPE-002003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-003002"
fi
echo ;


echo Negative extraction test 3. Attempting to extract a template from a file with more than one voice
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @Resources/sound_double_voice.wav --output Resources/trash/bio_template_c http://${1}/pattern/extract)
echo HTTP status: $RESULT
YY=`cat Resources/trash/bio_template_c`
echo json status: $YY
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$YY" =~ "BPE-003001" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-003001"
fi
echo ;


echo Negative extraction test 4. Uses in request incorrect content-type
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/sound.wav --output Resources/trash/bio_template_d http://${1}/pattern/extract)
echo HTTP status: $RESULT
QQ=`cat Resources/trash/bio_template_d`
echo json status: $QQ
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$QQ" =~ "BPE-002001" ]];
then 
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-002001"
fi
echo ;


echo Negative extraction test 5. Invalid http request method
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" -H "Expect:" --data-binary @Resources/sound.wav --output Resources/trash/bio_template_e -X GET http://${1}/pattern/extract)
echo HTTP status: $RESULT
WW=`cat Resources/trash/bio_template_e`
echo json status: $WW
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$WW" =~ "BPE-002002" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-002002"
fi
echo ;


echo Negative extraction test 6. Trying to create a template from photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:audio/pcm" --data-binary "@Resources/photo.jpg" --output Resources/trash/bio_template_z http://${1}/pattern/extract)
echo HTTP status: $RESULT
BV=`cat Resources/trash/bio_template_z`
echo json status: $BV 
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$BV" =~ "BPE-002003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call extract result. Error expected BPE-002003"
fi
echo ;


echo Negative compare test 1. Uses in request incorrect content-type
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "Resources/bio_feature=@template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" --output Resources/trash/bio_template_f -X POST http://${1}/pattern/compare) 
echo HTTP status: $RESULT
BB=`cat Resources/trash/bio_template_f`
echo json status: $BB
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$BB" =~ "BPE-002001" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002001"
fi
echo ;


echo Positive compare test
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -X POST http://${1}/pattern/compare)
MMM=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -X POST http://${1}/pattern/compare| sed 's/....$//' | sed "s/[^.]*\.//")
echo $RESULT
if [[ "$RESULT" =~ "200" ]]; then
	if [[ "$RESULT" =~ "." ]]; then
		if [[ "$MMM" == *[0-9]* ]]; then
			echo "Result - Good"
		else 
		echo "Result - Bad. HTTP status good, but score must contain numbers after the period"
		fi 
	else
	echo "Result - Bad. HTTP status good, but score not type double"
	fi
else
echo "Result - Bad. Http answer bad. Should be 200"	
fi
echo ;


echo Negative compare test 2. Comparing an empty template with a template
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template_empty;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" --output Resources/trash/bio_template_j -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_j`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002004"
fi
echo ;


echo Negative compare test 3. Comparing a template with an empty template
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" --output Resources/trash/bio_template_l -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_l`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Must be 400"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002004"
fi
echo ;


echo Negative compare test 4. Comparing an empty template with an empty template
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template_empty;type=application/octet-stream" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" --output Resources/trash/bio_template_m -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_m`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Must be 400"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002004"
fi
echo ;


echo Negative compare test 5. Invalid http request method
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" --output Resources/trash/bio_template_x -X GET http://${1}/pattern/compare)
echo HTTP status: $RESULT
XP=`cat Resources/trash/bio_template_x`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$XP" =~ "BPE-002002" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002002"
fi
echo ;


echo Negative compare test 6. Invalid Content-Type for bio_furure
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=image/jpeg" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" --output Resources/trash/bio_template_xz http://${1}/pattern/compare)
echo HTTP status: $RESULT
XP=`cat Resources/trash/bio_template_xz`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$XP" =~ "BPE" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result"
fi
echo ;


echo Negative compare test 7. Invalid Content-Type for bio_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/template/bio_template_a;type=image/jpeg" --output Resources/trash/bio_template_xzy http://${1}/pattern/compare)
echo HTTP status: $RESULT
XP=`cat Resources/trash/bio_template_xzy`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$XP" =~ "BPE" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result"
fi
echo ;


echo Negative compare test 8. Compare template with sound file
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/template/bio_template_a;type=application/octet-stream" -F "bio_template=@Resources/sound.wav;type=application/octet-stream" --output Resources/trash/bio_template_xzy http://${1}/pattern/compare)
echo HTTP status: $RESULT
XP=`cat Resources/trash/bio_template_xzy`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$XP" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call compare result. Error expected BPE-002004"
fi
echo ;


echo Negative verify test 1. Invalid http request method
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound.wav;type=audio/pcm" --output Resources/trash/bio_template_qzzz -X GET http://${1}/pattern/verify)
echo HTTP status: $RESULT
BF=`cat Resources/trash/bio_template_qzzz`
echo json status: $BF
if [[ "$RESULT" =~ "400" ]] && [[ "$BF" =~ "BPE-002002" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$BF" =~ "BPE-002002" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002002"
fi
echo ;


echo Negative verify test 2. Uses in request incorrect content-type
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound.wav;type=audio/pcm" --output Resources/trash/bio_template_i http://${1}/pattern/verify)
echo HTTP status: $RESULT
UI=`cat Resources/trash/bio_template_i`
echo json status: $UI
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$UI" =~ "BPE-002001" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002001"
fi
echo ;


echo Negative verify test 3. Attempting to extract a template from a file of zero size
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/empty.wav;type=audio/pcm" --output Resources/trash/bio_template_g http://${1}/pattern/verify)
echo HTTP status: $RESULT
IO=`cat Resources/trash/bio_template_g`
echo json status: $IO
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$IO" =~ "BPE-002003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002003"
fi
echo ;


echo Negative verify test 4. Trying to compose an empty template with an good sound
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" -F "sample=@Resources/sound.wav;type=audio/pcm" --output Resources/trash/bio_template_k http://${1}/pattern/verify)
echo HTTP status: $RESULT
NH=`cat Resources/trash/bio_template_k`
echo json status: $NH
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$NH" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002004"
fi
echo ;


echo Negative verify test 5. Comparing an empty template with an empty file
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" -F "sample=@Resources/empty.wav;type=audio/pcm" --output Resources/trash/bio_template_o http://${1}/pattern/verify)
echo HTTP status: $RESULT
NH=`cat Resources/trash/bio_template_o`
echo json status: $NH
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Must be 400"
fi
if [[ "$NH" =~ "BPE-002003" ]] || [[ "$NH" =~ "BPE-002004" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002004 or BPE-002003"
fi
echo ;


echo Negative verify test 6. Attempting to extract a template from a file without voice
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound_without_voice.wav;type=audio/pcm" --output Resources/trash/bio_template_p http://${1}/pattern/verify)
echo HTTP status: $RESULT
GT=`cat Resources/trash/bio_template_p`
echo json status: $GT
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$GT" =~ "BPE-003001" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-003001"
fi
echo ;


echo Negative verify test 7. Attempting to extract a template from a file with more than one voice
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound_without_voice.wav;type=audio/pcm" --output Resources/trash/bio_template_s http://${1}/pattern/verify)
echo HTTP status: $RESULT
HJ=`cat Resources/trash/bio_template_s`
echo json status: $HJ
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$HJ" =~ "BPE-003003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-003003"
fi
echo ;


echo Negative verify test 8. Incorrect Content-Type for sample
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound.wav;type=image/jpeg" --output Resources/trash/bio_template_sy http://${1}/pattern/verify)
echo HTTP status: $RESULT
HJ=`cat Resources/trash/bio_template_sy`
echo json status: $HJ
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$HJ" =~ "BPE-002005" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002005"
fi
echo ;


echo Negative verify test 9. Incorrect Content-Type for bio_template
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/json" -F "sample=@Resources/sound.wav;type=audio/pcm" --output Resources/trash/bio_template_su http://${1}/pattern/verify)
echo HTTP status: $RESULT
HJ=`cat Resources/trash/bio_template_su`
echo json status: $HJ
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$HJ" =~ "BPE-002005" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002005"
fi
echo ;


echo Negative verify test 10. Extract template from photo
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/json" -F "sample=@Resources/photo.jpg;type=audio/pcm" --output Resources/trash/bio_template_su http://${1}/pattern/verify)
echo HTTP status: $RESULT
HJ=`cat Resources/trash/bio_template_su`
echo json status: $HJ
if [[ "$RESULT" =~ "400" ]];
then
echo "Http answer correct"
else
echo "Http answer bad. Should be 400"
fi
if [[ "$HJ" =~ "BPE-002003" ]];
then
echo "Result - Good"
else
echo "Result - Bad. Got a call verify result. Error expected BPE-002003"
fi
echo ;


echo Positive verify test 1
#RTY=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@bio_template;type=application/octet-stream" -F "sample=@photo.jpg;type=image/jpeg" --output trash/bio_template_good_2  http://${1}/pattern/verify)
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/template/bio_template_a;type=application/octet-stream" -F "sample=@Resources/sound.wav;type=audio/pcm" --output Resources/trash/bio_template_good_1  http://${1}/pattern/verify)
RTY=`cat Resources/trash/bio_template_good_1 | grep -a score`
RUI=`cat Resources/trash/bio_template_good_1 | grep -a score | sed "s/[^.]*\.//"`
TVZ=`cat Resources/trash/bio_template_good_1 | tail -n 2 Resources/trash/bio_template_good_1 > Resources/trash/ver_template` 
XRT=`head -1 Resources/trash/ver_template > Resources/trash/ll`
DDDD=`du -b trash/ll`
echo HTTP status: $RESULT
echo Size and name of response $DDDD
if [ "$RESULT" == "200" ]; then
	if [[ "$RTY" =~ "." ]]; then
		if [[ "$RUI" == *[0-9]* ]]; then
			if [[ "$DDDD" == *[1-9]* ]]; then
			echo "Result - Good"
			else
			echo "Result - Bad. Template is empty or response format does not comply with guidelines"
			fi
		else
		echo "Result - Bad. HTTP status good, but score must contain numbers after the period"
		fi
	else
	echo "Result - Bad. HTTP status good, but score not type double"
	fi
else
echo "Result - Bad. Http answer bad. Should be 200"
fi
echo ;


echo Positive verify test 2. boundary
cat Resources/file1_3 > Resources/final_body2
cat Resources/template/bio_template_a >> Resources/final_body2
cat Resources/file2_3 >> Resources/final_body2
cat Resources/sound.wav >> Resources/final_body2
cat Resources/file3_3 >> Resources/final_body2
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data; boundary=------------------------------5347ce9cdd36_" --data-binary @Resources/final_body2 --output Resources/trash/bio_template_good_2  http://${1}/pattern/verify)
RTY=`cat Resources/trash/bio_template_good_2 | grep -a score`
RUI=`cat Resources/trash/bio_template_good_2 | grep -a score | sed "s/[^.]*\.//"`
TVZ=`cat Resources/trash/bio_template_good_2 | tail -n 2 Resources/trash/bio_template_good_2 > Resources/trash/ver_template2`
XRT=`head -1 Resources/trash/ver_template2 > Resources/trash/ll2`
DDDD=`du -b Resources/trash/ll2`
echo HTTP status: $RESULT
echo Size and name of response $DDDD
if [ "$RESULT" == "200" ]; then
        if [[ "$RTY" =~ "." ]]; then
                if [[ "$RUI" == *[0-9]* ]]; then
                        if [[ "$DDDD" == *[1-9]* ]]; then
                        echo "Result - Good"
                        else
                        echo "Result - Bad. Template is empty or response format does not comply with guidelines"
                        fi
                else
                echo "Result - Bad. HTTP status good, but score must contain numbers after the period"
                fi
        else
        echo "Result - Bad. HTTP status good, but score not type double"
        fi
else
echo "Result - Bad. Http answer bad. Should be 200"
fi
echo ;


echo Positive verify test 3. Without filename
cat Resources/file1_4 > Resources/final_body3
cat Resources/template/bio_template_a >> Resources/final_body3
cat Resources/file2_4 >> Resources/final_body3
cat Resources/sound.wav >> Resources/final_body3
cat Resources/file3_4 >> Resources/final_body3
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data; boundary=------------------------------5347ce9cdd36_" --data-binary @Resources/final_body3 --output Resources/trash/bio_template_good_3  http://${1}/pattern/verify)
RTY=`cat Resources/trash/bio_template_good_3 | grep -a score`
RUI=`cat Resources/trash/bio_template_good_3 | grep -a score | sed "s/[^.]*\.//"`
TVZ=`cat Resources/trash/bio_template_good_3 | tail -n 2 Resources/trash/bio_template_good_3 > Resources/trash/ver_template3`
XRT=`head -1 Resources/trash/ver_template3 > Resources/trash/ll3`
DDDD=`du -b Resources/trash/ll3`
echo HTTP status: $RESULT
echo Size and name of response $DDDD
if [ "$RESULT" == "200" ]; then
        if [[ "$RTY" =~ "." ]]; then
                if [[ "$RUI" == *[0-9]* ]]; then
                        if [[ "$DDDD" == *[1-9]* ]]; then
                        echo "Result - Good"
                        else
                        echo "Result - Bad. Template is empty or response format does not comply with guidelines"
                        fi
                else
                echo "Result - Bad. HTTP status good, but score must contain numbers after the period"
                fi
        else
        echo "Result - Bad. HTTP status good, but score not type double"
        fi
else
echo "Result - Bad. Http answer bad. Should be 200"
fi




























