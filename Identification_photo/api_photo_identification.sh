echo Checking the status of the biometric processor
RESULT=$(curl http://${1}/v1/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "Result - Passed. Biometric processor is working correctly"
else
echo "Result - Bad. Biometric processor does not work correctly"
fi
echo ;


echo Positive extraction test 1. Extract jpeg photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/bio_template http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b bio_template`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
	if [[ "$PLM" == *[1-9]* ]]; then
			echo "Result - Passed"
				
		else
		echo "HTTP status Passed, but template empty"
		fi
else
echo "Result - Failed."
fi
echo ;


echo Positive extraction test 2. Extract png photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.png --output Resources/trash/bio_template_a http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/trash/bio_template_a`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
        if [[ "$PLM" == *[1-9]* ]]; then
                        echo "Result - Passed"

                else
                echo "HTTP status Passed, but template empty"
                fi
else
echo "Result - Failed."
fi
echo ;


echo Positive extraction test 3. Using lower case in spelling content-type
RESULT=$(curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_e http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/trash/bio_template_e`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
        if [[ "$PLM" == *[1-9]* ]]; then
                        echo "Result - Passed"

                else
                echo "HTTP status Passed, but template empty"
                fi
else
echo "Result - Failed."
fi
echo ;


echo Negative extraction test 1. Uses in request incorrect Content-Type
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_f http://${1}/v1/extract)
echo HTTP status: $RESULT
BV=`cat Resources/trash/bio_template_f`
echo json status: $BV
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BV" =~ "BPE-002001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002001"
fi
echo ;


echo Negative extraction test 2. Invalid http request method 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_g -X GET http://${1}/v1/extract)
echo HTTP status: $RESULT
BQ=`cat Resources/trash/bio_template_g`
echo json status: $BQ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BQ" =~ "BPE-002002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002002"
fi
echo ;


echo Negative extraction test 3. Attempting to extract a template from a file of zero size
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/empty.jpeg --output Resources/trash/bio_template_h http://${1}/v1/extract)
echo HTTP status: $RESULT
BW=`cat Resources/trash/bio_template_h`
echo json status: $BW
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BW" =~ "BPE-002003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002003"
fi
echo ;


echo Negative extraction test 4.  Attempting to extract a template from an audio file
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/audio.wav --output Resources/trash/bio_template_i http://${1}/v1/extract)
echo HTTP status: $RESULT
BW=`cat Resources/trash/bio_template_i`
echo json status: $BW
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BW" =~ "BPE-002003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002003"
fi
echo ;


echo Negative extraction test 5. Attempting to extract a template from a broken file
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/broken_file.jpeg --output Resources/trash/bio_template_j http://${1}/v1/extract)
echo HTTP status: $RESULT
BE=`cat Resources/trash/bio_template_j`
echo json status: $BE
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BE" =~ "BPE-002003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002003"
fi
echo ;


echo Negative extraction test 6. Attempting to extract a template from a photo without face
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/without_face.jpg --output Resources/trash/bio_template_k http://${1}/v1/extract)
echo HTTP status: $RESULT
BR=`cat Resources/trash/bio_template_k`
echo json status: $BR
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BR" =~ "BPE-003002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003002"
fi
echo ;


echo Negative extraction test 7. Attempting to extract a template from a photo with more than one face
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/more_then_one_face.jpg --output Resources/trash/bio_template_l http://${1}/v1/extract)
echo HTTP status: $RESULT
BT=`cat Resources/trash/bio_template_l`
echo json status: $BT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BT" =~ "BPE-003003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003003"
fi
echo ;


echo Positive add test 1
PREDATA=$(curl -s -w "%{http_code}" -H 'Content-Type: application/json' -H 'X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a' --data '{"template_id": "12345"}' -X POST http://${1}/v1/delete)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res1 http://${1}/v1/add)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "Result - Passed."
else
echo "Result - Bad. Failed"
fi
echo ;


echo Negative add test 1. Adding with the name that is in the database
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res2 http://${1}/v1/add)
echo HTTP status: $RESULT
BTT=`cat Resources/trash/add_res2`
echo json status: $BTT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BTT" =~ "BPE-00507" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00507"
fi
echo ;


echo Negative add test 2. Uses in request incorrect Content-Type
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:ppplication/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res3 http://${1}/v1/add)
echo HTTP status: $RESULT
BY=`cat Resources/trash/add_res3`
echo json status: $BY
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BY" =~ "BPE-002001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002001"
fi
echo ;


echo Negative add test 3. Invalid http request method  
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res4 -X GET http://${1}/v1/add)
echo HTTP status: $RESULT
BU=`cat Resources/trash/add_res4`
echo json status: $BU
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BU" =~ "BPE-002002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002002"
fi
echo ;


echo Negative add test 4. Request with broken template
PRETEST=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' http://${1}/v1/delete)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res5 http://${1}/v1/add)
echo delete: $PRETEST
echo HTTP status: $RESULT
BO=`cat Resources/trash/add_res5`
echo json status: $BO
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BO" =~ "BPE-002004" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002004"
fi
echo ;


echo Negative add test 5. Bad meta   
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/add_res6 http://${1}/v1/add)
echo HTTP status: $RESULT
BP=`cat Resources/trash/add_res6`
echo json status: $BP
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BP" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative add test 6. Bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345",};type=application/json' --output Resources/trash/add_res7 http://${1}/v1/add)
echo HTTP status: $RESULT
BP=`cat Resources/trash/add_res7`
echo json status: $BP
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BP" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative add test 7. BPE-00502
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":""};type=application/json' --output Resources/trash/add_res10 http://${1}/v1/add)
echo HTTP status: $RESULT
BSS=`cat Resources/trash/add_res10`
echo json status: $BSS
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BSS" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative add test 8. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res12 http://${1}/v1/add)
echo HTTP status: $RESULT
BLL=`cat Resources/trash/add_res12`
echo json status: $BLL
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BLL" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative add test 9. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res13 http://${1}/v1/add)
echo HTTP status: $RESULT
BY=`cat Resources/trash/add_res13`
echo json status: $BY
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BY" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative add test 10. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/add_res14 http://${1}/v1/add)
echo HTTP status: $RESULT
BYY=`cat Resources/trash/add_res14`
echo json status: $BYY
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BYY" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative add test 11. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/add_res15 http://${1}/v1/add)
echo HTTP status: $RESULT
TTT=`cat Resources/trash/add_res15`
echo json status: $TTT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$TTT" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Positive update
PREDATA=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' http://${1}/v1/add)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res1 http://${1}/v1/update)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "Result - Passed."
else
echo "Result - Bad. Failed"
fi
echo ;


echo  Negative update test 1. Uses in request incorrect content-type
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:pplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res2 http://${1}/v1/update)
echo HTTP status: $RESULT
BD=`cat Resources/trash/update_res2`
echo json status: $BD
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BD" =~ "BPE-002001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002001"
fi
echo ;


echo Negative update test 2. Invalid http request method
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res3 -X GET http://${1}/v1/update)
echo HTTP status: $RESULT
BG=`cat Resources/trash/update_res3`
echo json status: $BG
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BG" =~ "BPE-002002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002002"
fi
echo ;


echo Negative update test 3. BPE-002004
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res4 http://${1}/v1/update)
echo HTTP status: $RESULT
BH=`cat Resources/trash/update_res4`
echo json status: $BH
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BH" =~ "BPE-002004" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002004"
fi
echo ;


echo Negative update test 4. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/update_res5 http://${1}/v1/update)
echo HTTP status: $RESULT
BJ=`cat Resources/trash/update_res5`
echo json status: $BJ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BJ" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative update test 5. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12353",};type=application/json' --output Resources/trash/update_res6 http://${1}/v1/update)
echo HTTP status: $RESULT
BJ=`cat Resources/trash/update_res6`
echo json status: $BJ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BJ" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative update test 6. BPE-00502 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"id":"12354"};type=application/json' --output Resources/trash/update_res7 http://${1}/v1/update)
echo HTTP status: $RESULT
BK=`cat Resources/trash/update_res7`
echo json status: $BK
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BK" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative update test 7. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"template_id":"12354"};type=application/json' --output Resources/trash/update_res9 http://${1}/v1/update)
echo HTTP status: $RESULT
BKK=`cat Resources/trash/update_res9`
echo json status: $BKK
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BKK" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative update test 8. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"template_id":"12354"};type=application/json' --output Resources/trash/update_res10 http://${1}/v1/update)
echo HTTP status: $RESULT
BKL=`cat Resources/trash/update_res10`
echo json status: $BKL
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BKL" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative update test 9. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/update_res11 http://${1}/v1/update)
echo HTTP status: $RESULT
ZZ=`cat Resources/trash/update_res11`
echo json status: $ZZ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$ZZ" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative update test 10. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/update_res12 http://${1}/v1/update)
echo HTTP status: $RESULT
ZZL=`cat Resources/trash/update_res12`
echo json status: $ZZL
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$ZZL" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Positive match test
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res1 http://${1}/v1/match)
echo HTTP status: $RESULT
CV=`cat Resources/trash/match_res1`
if [ "$RESULT" == "200" ]; then
echo "Result - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$CV" =~ "template_id" ]]; then
echo "template_id is in the answer"
else
echo "template_id no answer"
fi
if [[ "$CV" =~ "similarity" ]]; then
echo "similarity is in the answer"
else
echo "similarity no answer"
fi
echo ;


echo Negative match test 1. Uses in request incorrect content-type 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:ppplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res2 http://${1}/v1/match)
echo HTTP status: $RESULT
BZ=`cat Resources/trash/match_res2`
echo json status: $BZ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BZ" =~ "BPE-002001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002001"
fi
echo ;


echo Negative match test 2. Invalid http request method
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res3 -X GET http://${1}/v1/match)
echo HTTP status: $RESULT
BX=`cat Resources/trash/match_res3`
echo json status: $BX
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BX" =~ "BPE-002002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002002"
fi
echo ;


echo Negative match test 3. BPE-002004 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res4 http://${1}/v1/match)
echo HTTP status: $RESULT
BC=`cat Resources/trash/match_res4`
echo json status: $BC
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BC" =~ "BPE-002004" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002004"
fi
echo ;


echo Negative match test 4. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/match_res5 http://${1}/v1/match)
echo HTTP status: $RESULT
BB=`cat Resources/trash/match_res5`
echo json status: $BB
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BB" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;
 

echo Negative match test 5. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5,};type=application/json' --output Resources/trash/match_res6 http://${1}/v1/match)
echo HTTP status: $RESULT
BB=`cat Resources/trash/match_res6`
echo json status: $BB
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BB" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative match test 6. Request without limit 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3};type=application/json' --output Resources/trash/match_res7 http://${1}/v1/match)
echo HTTP status: $RESULT
BN=`cat Resources/trash/match_res7`
echo json status: $BN
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BN" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative match test 7. Request without threshold
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"limit": 5};type=application/json' --output Resources/trash/match_res8 http://${1}/v1/match)
echo HTTP status: $RESULT
BN=`cat Resources/trash/match_res8`
echo json status: $BN
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$BN" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative match test 8. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res10 http://${1}/v1/match)
echo HTTP status: $RESULT
NN=`cat Resources/trash/match_res10`
echo json status: $NN
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$NN" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative match test 9. Request without template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res11 http://${1}/v1/match)
echo HTTP status: $RESULT
NNT=`cat Resources/trash/match_res11`
echo json status: $NNT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$NNT" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative match test 10. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/match_res12 http://${1}/v1/match)
echo HTTP status: $RESULT
NNR=`cat Resources/trash/match_res12`
echo json status: $NNR
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$NNR" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative match test 11. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/match_res13 http://${1}/v1/match)
echo HTTP status: $RESULT
NNZ=`cat Resources/trash/match_res13`
echo json status: $NNZ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$NNZ" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Positive identify test
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res1 http://${1}/v1/identify)
echo HTTP status: $RESULT
VV=`cat Resources/trash/identify_res1`
if [ "$RESULT" == "200" ]; then
echo "Result - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$VV" =~ "template_id" ]]; then
echo "template_id is in the answer"
else
echo "template_id no answer"
fi
if [[ "$VV" =~ "similarity" ]]; then
echo "similarity is in the answer"
else
echo "similarity no answer"
fi
echo ;


echo Negative identify test 1. Uses in request incorrect content-type 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:part/fordata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res2 http://${1}/v1/identify)
echo HTTP status: $RESULT
QQ=`cat Resources/trash/identify_res2`
echo json status: $QQ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QQ" =~ "BPE-002001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002001"
fi
echo ;


echo Negative identify test 2. Invalid http request method
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res3 -X GET http://${1}/v1/identify)
echo HTTP status: $RESULT
QW=`cat Resources/trash/identify_res3`
echo json status: $QW
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QW" =~ "BPE-002002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002002"
fi
echo ;


echo Negative identify test 3. BPE-002003 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/broken_file.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res4 http://${1}/v1/identify)
echo HTTP status: $RESULT
QE=`cat Resources/trash/identify_res4`
echo json status: $QE
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QE" =~ "BPE-002003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002003"
fi
echo ;


echo Negative identify test 4. Invalid content-type part of multipart photo 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=audio/pcm' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res5 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res5`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QR" =~ "BPE-002005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002005"
fi
echo ;


echo Negative identify test 5. Invalid content-type part of multipart metadata
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=iage/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=image/jpeg' --output Resources/trash/identify_res6 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res6`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QR" =~ "BPE-002005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002005"
fi
echo ;


echo Negative identify test 6. Invalid content-type part of multipart metadata and photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=audio/wav' -F 'metadata={"threshold": 0.3, "limit": 5};type=image/jpeg' --output Resources/trash/identify_res7 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res7`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QR" =~ "BPE-002005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002005"
fi
echo ;


echo Negative identify test 7. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"eyJ0cmVzaG9sZCI6IDAuMywgImxpbWl0IjogNX0="};type=application/json' --output Resources/trash/identify_res8 http://${1}/v1/identify)
echo HTTP status: $RESULT
QT=`cat Resources/trash/identify_res8`
echo json status: $QT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QT" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative identify test 8. BPE-00005 bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5,};type=application/json' --output Resources/trash/identify_res9 http://${1}/v1/identify)
echo HTTP status: $RESULT
QT=`cat Resources/trash/identify_res9`
echo json status: $QT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QT" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative identify test 9. Request without treshold
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"limit": 5};type=application/json' --output Resources/trash/identify_res10 http://${1}/v1/identify)
echo HTTP status: $RESULT
QY=`cat Resources/trash/identify_res10`
echo json status: $QY
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QY" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative identify test 10. Request without limit
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3};type=application/json' --output Resources/trash/identify_res11 http://${1}/v1/identify)
echo HTTP status: $RESULT
QY=`cat Resources/trash/identify_res11`
echo json status: $QY
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QY" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative identify test 11. BPE-003001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/empty.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res13 http://${1}/v1/identify)
echo HTTP status: $RESULT
QO=`cat Resources/trash/identify_res13`
echo json status: $QO
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QO" =~ "BPE-003001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003001"
fi
echo ;


echo Negative identify test 12. Request with photo without face
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/without_face.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res14 http://${1}/v1/identify)
echo HTTP status: $RESULT
QP=`cat Resources/trash/identify_res14`
echo json status: $QP
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QP" =~ "BPE-003002" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003002"
fi
echo ;


echo Negative identify test 13. Request with photo with more than one face
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/more_then_one_face.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res15 http://${1}/v1/identify)
echo HTTP status: $RESULT
QA=`cat Resources/trash/identify_res15`
echo json status: $QA
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QA" =~ "BPE-003003" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003003"
fi
echo ;


echo Negative identify test 14. Request with audio
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/sound.wav;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res16 http://${1}/v1/identify)
echo HTTP status: $RESULT
QOT=`cat Resources/trash/identify_res16`
echo json status: $QOT
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QOT" =~ "BPE-003001" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-003001"
fi
echo ;


echo Negative identify test 15. Request without photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res17 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTB=`cat Resources/trash/identify_res17`
echo json status: $QTB
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QTB" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative identify test 16. Request without photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res18 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTP=`cat Resources/trash/identify_res18`
echo json status: $QTP
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QTP" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative identify test 17. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata=;type=application/json' --output Resources/trash/identify_res19 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTQ=`cat Resources/trash/identify_res19`
echo json status: $QTQ
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QTQ" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Negative identify test 18. Request without meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' --output Resources/trash/identify_res20 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTU=`cat Resources/trash/identify_res20`
echo json status: $QTU
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QTU" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;


echo Positive delete test 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res1 http://${1}/v1/delete)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "Result - Passed."
else
echo "Result - Bad. Failed"
fi
echo ;


echo Negative delete test 1. Template has already been deleted
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res8 http://${1}/v1/delete)
echo HTTP status: $RESULT
QSS=`cat Resources/trash/delete_res8`
echo json status: $QSS
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QSS" =~ "BPE-002404" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002404"
fi
echo ;


echo Negative delete test 2. Incorrect request
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res2 -X GET http://${1}/v1/delete)
echo HTTP status: $RESULT
QS=`cat Resources/trash/delete_res2`
echo json status: $QS
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QS" =~ "BPE-002006" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-002006"
fi
echo ;


echo  Negative delete test 3. Bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="}' --output Resources/trash/delete_res4 http://${1}/v1/delete)
echo HTTP status: $RESULT
QG=`cat Resources/trash/delete_res4`
echo json status: $QG
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QG" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo  Negative delete test 4. Bad meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"01010101001010",}' --output Resources/trash/delete_res5 http://${1}/v1/delete)
echo HTTP status: $RESULT
QG=`cat Resources/trash/delete_res5`
echo json status: $QG
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QG" =~ "BPE-00005" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00005"
fi
echo ;


echo Negative delete test 5. BPE-00502 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" --data 'metadata={}' --output Resources/trash/delete_res6 http://${1}/v1/delete)
echo HTTP status: $RESULT
QH=`cat Resources/trash/delete_res6`
echo json status: $QH
if [ "$RESULT" == "400" ]; then
echo "Result http answer - Passed."
else
echo "Result - Bad. Failed"
fi
if [[ "$QH" =~ "BPE-00502" ]];
then
echo "Result code - Passed"
else
echo "Result - Bad.Error expected BPE-00502"
fi
echo ;

