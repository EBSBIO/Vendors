echo health.200
RESULT=$(curl http://${1}/v1/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "OK"
else
echo "FAIL"
fi
echo ;


echo extract.200.JPG
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/bio_template http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/bio_template`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
	if [[ "$PLM" == *[1-9]* ]]; then
			echo "OK"

		else
		echo "FAIL (score is expected)"
		fi
else
echo "FAIL"
fi
echo ;


echo extract.200.PNG
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.png --output Resources/trash/bio_template_a http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/trash/bio_template_a`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
        if [[ "$PLM" == *[1-9]* ]]; then
                        echo "OK"

                else
                echo "FAIL (score is expected)"
                fi
else
echo "FAIL"
fi
echo ;


echo extract.200.content_type_to_lower_case
RESULT=$(curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_e http://${1}/v1/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/trash/bio_template_e`
echo Size and name of template: $PLM
if [ "$RESULT" == "200" ]; then
        if [[ "$PLM" == *[1-9]* ]]; then
                        echo "OK"

                else
                echo "FAIL (score is expected)"
                fi
else
echo "FAIL"
fi
echo ;


echo extract.400.BPE-002001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_f http://${1}/v1/extract)
echo HTTP status: $RESULT
BV=`cat Resources/trash/bio_template_f`
echo json status: $BV
if [ "$RESULT" == "400" ]; then
	if [[ "$BV" =~ "BPE-002001" ]]; then
		echo "OK"
	else
		echo "FAIL (BPE-002001 is expected)"
	fi
else
	echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-002002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/photo.jpeg --output Resources/trash/bio_template_g -X GET http://${1}/v1/extract)
echo HTTP status: $RESULT
BQ=`cat Resources/trash/bio_template_g`
echo json status: $BQ
if [ "$RESULT" == "400" ]; then
	if [[ "$BQ" =~ "BPE-002002" ]]; then
		echo "OK"
	else
		echo "FAIL (BPE-002002 is expected)"
	fi
else
	echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-002003.empty
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/empty.jpeg --output Resources/trash/bio_template_h http://${1}/v1/extract)
echo HTTP status: $RESULT
BW=`cat Resources/trash/bio_template_h`
echo json status: $BW
if [ "$RESULT" == "400" ]; then
	if [[ "$BW" =~ "BPE-002003" ]]; then
		echo "OK"
	else
		echo "FAIL (BPE-002003 is expected)"
	fi
else
	echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-002003.sound
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/audio.wav --output Resources/trash/bio_template_i http://${1}/v1/extract)
echo HTTP status: $RESULT
BW=`cat Resources/trash/bio_template_i`
echo json status: $BW
if [ "$RESULT" == "400" ]; then
        if [[ "$BW" =~ "BPE-002003" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002003 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-002003.broken
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/broken_file.jpeg --output Resources/trash/bio_template_j http://${1}/v1/extract)
echo HTTP status: $RESULT
BE=`cat Resources/trash/bio_template_j`
echo json status: $BE
if [ "$RESULT" == "400" ]; then
        if [[ "$BE" =~ "BPE-002003" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002003 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-003002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/without_face.jpg --output Resources/trash/bio_template_k http://${1}/v1/extract)
echo HTTP status: $RESULT
BR=`cat Resources/trash/bio_template_k`
echo json status: $BR
if [ "$RESULT" == "400" ]; then
        if [[ "$BR" =~ "BPE-003002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo extract.400.BPE-003003
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data-binary @Resources/more_then_one_face.jpg --output Resources/trash/bio_template_l http://${1}/v1/extract)
echo HTTP status: $RESULT
BT=`cat Resources/trash/bio_template_l`
echo json status: $BT
if [ "$RESULT" == "400" ]; then
        if [[ "$BT" =~ "BPE-003003" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003003 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.200
PREDATA=$(curl -s -w "%{http_code}" -H 'Content-Type: application/json' -H 'X-Request-ID: 1c0944b1-0f46-4e51-a8b0-693e9e44952a' --data '{"template_id": "12345"}' -X POST http://${1}/v1/delete)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res1 http://${1}/v1/add)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "OK"
else
echo "FAIL"
fi
echo ;

echo add.400.BPE-00507
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res2 http://${1}/v1/add)
echo HTTP status: $RESULT
BTT=`cat Resources/trash/add_res2`
echo json status: $BTT
if [ "$RESULT" == "400" ]; then
        if [[ "$BTT" =~ "BPE-00507" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00507 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-002001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:ppplication/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res3 http://${1}/v1/add)
echo HTTP status: $RESULT
BY=`cat Resources/trash/add_res3`
echo json status: $BY
if [ "$RESULT" == "400" ]; then
        if [[ "$BY" =~ "BPE-002001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo  add.400.BPE-002002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res4 -X GET http://${1}/v1/add)
echo HTTP status: $RESULT
BU=`cat Resources/trash/add_res4`
echo json status: $BU
if [ "$RESULT" == "400" ]; then
        if [[ "$BU" =~ "BPE-002002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-002004
PRETEST=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' http://${1}/v1/delete)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res5 http://${1}/v1/add)
echo delete: $PRETEST
echo HTTP status: $RESULT
BO=`cat Resources/trash/add_res5`
echo json status: $BO
if [ "$RESULT" == "400" ]; then
        if [[ "$BO" =~ "BPE-002004" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00005.broken
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/add_res6 http://${1}/v1/add)
echo HTTP status: $RESULT
BP=`cat Resources/trash/add_res6`
echo json status: $BP
if [ "$RESULT" == "400" ]; then
        if [[ "$BP" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo  add.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345",};type=application/json' --output Resources/trash/add_res7 http://${1}/v1/add)
echo HTTP status: $RESULT
BP=`cat Resources/trash/add_res7`
echo json status: $BP
if [ "$RESULT" == "400" ]; then
        if [[ "$BP" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00502
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":""};type=application/json' --output Resources/trash/add_res10 http://${1}/v1/add)
echo HTTP status: $RESULT
BSS=`cat Resources/trash/add_res10`
echo json status: $BSS
if [ "$RESULT" == "400" ]; then
        if [[ "$BSS" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00502.no_template_file
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res12 http://${1}/v1/add)
echo HTTP status: $RESULT
BLL=`cat Resources/trash/add_res12`
echo json status: $BLL
if [ "$RESULT" == "400" ]; then
        if [[ "$BLL" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00502.no_template_part
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res13 http://${1}/v1/add)
echo HTTP status: $RESULT
BY=`cat Resources/trash/add_res13`
echo json status: $BY
if [ "$RESULT" == "400" ]; then
        if [[ "$BY" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00502.no_meta_file
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/add_res14 http://${1}/v1/add)
echo HTTP status: $RESULT
BYY=`cat Resources/trash/add_res14`
echo json status: $BYY
if [ "$RESULT" == "400" ]; then
        if [[ "$BYY" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo add.400.BPE-00502.no_meta_part
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/add_res15 http://${1}/v1/add)
echo HTTP status: $RESULT
TTT=`cat Resources/trash/add_res15`
echo json status: $TTT
if [ "$RESULT" == "400" ]; then
        if [[ "$TTT" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.200
PREDATA=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' http://${1}/v1/add)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res1 http://${1}/v1/update)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "OK"
else
echo "FAIL"
fi
echo ;

echo update.400.BPE-002001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:pplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res2 http://${1}/v1/update)
echo HTTP status: $RESULT
BD=`cat Resources/trash/update_res2`
echo json status: $BD
if [ "$RESULT" == "400" ]; then
        if [[ "$BD" =~ "BPE-002001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-002002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res3 -X GET http://${1}/v1/update)
echo HTTP status: $RESULT
BG=`cat Resources/trash/update_res3`
echo json status: $BG
if [ "$RESULT" == "400" ]; then
        if [[ "$BG" =~ "BPE-002002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-002004
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/update_res4 http://${1}/v1/update)
echo HTTP status: $RESULT
BH=`cat Resources/trash/update_res4`
echo json status: $BH
if [ "$RESULT" == "400" ]; then
        if [[ "$BH" =~ "BPE-002004" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002004 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/update_res5 http://${1}/v1/update)
echo HTTP status: $RESULT
BJ=`cat Resources/trash/update_res5`
echo json status: $BJ
if [ "$RESULT" == "400" ]; then
        if [[ "$BJ" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12353",};type=application/json' --output Resources/trash/update_res6 http://${1}/v1/update)
echo HTTP status: $RESULT
BJ=`cat Resources/trash/update_res6`
echo json status: $BJ
if [ "$RESULT" == "400" ]; then
        if [[ "$BJ" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00502
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"id":"12354"};type=application/json' --output Resources/trash/update_res7 http://${1}/v1/update)
echo HTTP status: $RESULT
BK=`cat Resources/trash/update_res7`
echo json status: $BK
if [ "$RESULT" == "400" ]; then
        if [[ "$BK" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00502.no_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"template_id":"12354"};type=application/json' --output Resources/trash/update_res9 http://${1}/v1/update)
echo HTTP status: $RESULT
BKK=`cat Resources/trash/update_res9`
echo json status: $BKK
if [ "$RESULT" == "400" ]; then
        if [[ "$BKK" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00502.no_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"template_id":"12354"};type=application/json' --output Resources/trash/update_res10 http://${1}/v1/update)
echo HTTP status: $RESULT
BKL=`cat Resources/trash/update_res10`
echo json status: $BKL
if [ "$RESULT" == "400" ]; then
        if [[ "$BKL" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/update_res11 http://${1}/v1/update)
echo HTTP status: $RESULT
ZZ=`cat Resources/trash/update_res11`
echo json status: $ZZ
if [ "$RESULT" == "400" ]; then
        if [[ "$ZZ" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo update.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/update_res12 http://${1}/v1/update)
echo HTTP status: $RESULT
ZZL=`cat Resources/trash/update_res12`
echo json status: $ZZL
if [ "$RESULT" == "400" ]; then
        if [[ "$ZZL" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.200
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res1 http://${1}/v1/match)
echo HTTP status: $RESULT
CV=`cat Resources/trash/match_res1`
if [ "$RESULT" == "200" ]; then
	if [[ "$CV" =~ "template_id" ]]; then
		if [[ "$CV" =~ "similarity" ]]; then
			echo "OK"
		else
			echo "FAIL (similarity is expected"
		fi
	else
		echo "FAIL (template_id is expected)"
	fi
else
	echo "FAIL"
fi
echo ;

echo match.400.BPE-002001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:ppplication/form-Fata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res2 http://${1}/v1/match)
echo HTTP status: $RESULT
BZ=`cat Resources/trash/match_res2`
echo json status: $BZ
if [ "$RESULT" == "400" ]; then
        if [[ "$BZ" =~ "BPE-002001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-002002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res3 -X GET http://${1}/v1/match)
echo HTTP status: $RESULT
BX=`cat Resources/trash/match_res3`
echo json status: $BX
if [ "$RESULT" == "400" ]; then
        if [[ "$BX" =~ "BPE-002002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo  match.400.BPE-002004
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/broken_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res4 http://${1}/v1/match)
echo HTTP status: $RESULT
BC=`cat Resources/trash/match_res4`
echo json status: $BC
if [ "$RESULT" == "400" ]; then
        if [[ "$BC" =~ "BPE-002004" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002004 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo  match.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="};type=application/json' --output Resources/trash/match_res5 http://${1}/v1/match)
echo HTTP status: $RESULT
BB=`cat Resources/trash/match_res5`
echo json status: $BB
if [ "$RESULT" == "400" ]; then
        if [[ "$BB" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5,};type=application/json' --output Resources/trash/match_res6 http://${1}/v1/match)
echo HTTP status: $RESULT
BB=`cat Resources/trash/match_res6`
echo json status: $BB
if [ "$RESULT" == "400" ]; then
        if [[ "$BB" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo  match.400.BPE-00502.no_limit
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"threshold": 0.3};type=application/json' --output Resources/trash/match_res7 http://${1}/v1/match)
echo HTTP status: $RESULT
BN=`cat Resources/trash/match_res7`
echo json status: $BN
if [ "$RESULT" == "400" ]; then
        if [[ "$BN" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00502.no_threshold
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"limit": 5};type=application/json' --output Resources/trash/match_res8 http://${1}/v1/match)
echo HTTP status: $RESULT
BN=`cat Resources/trash/match_res8`
echo json status: $BN
if [ "$RESULT" == "400" ]; then
        if [[ "$BN" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00005.no_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@;type=application/octet-stream' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res10 http://${1}/v1/match)
echo HTTP status: $RESULT
NN=`cat Resources/trash/match_res10`
echo json status: $NN
if [ "$RESULT" == "400" ]; then
        if [[ "$NN" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00502.no_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/match_res11 http://${1}/v1/match)
echo HTTP status: $RESULT
NNT=`cat Resources/trash/match_res11`
echo json status: $NNT
if [ "$RESULT" == "400" ]; then
        if [[ "$NNT" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata=;type=application/json' --output Resources/trash/match_res12 http://${1}/v1/match)
echo HTTP status: $RESULT
NNR=`cat Resources/trash/match_res12`
echo json status: $NNR
if [ "$RESULT" == "400" ]; then
        if [[ "$NNR" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo match.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' --output Resources/trash/match_res13 http://${1}/v1/match)
echo HTTP status: $RESULT
NNZ=`cat Resources/trash/match_res13`
echo json status: $NNZ
if [ "$RESULT" == "400" ]; then
        if [[ "$NNZ" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.200
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res1 http://${1}/v1/identify)
echo HTTP status: $RESULT
VV=`cat Resources/trash/identify_res1`
if [ "$RESULT" == "200" ]; then
	if [[ "$VV" =~ "template_id" ]]; then
		if [[ "$VV" =~ "similarity" ]]; then
			echo "OK"
		else
			echo "FAIL (similarity is expected)"
		fi
	else
		echo "FAIL (template_id is expected)"
	fi
else
	echo "FAIL"
fi
echo ;

echo identify.400.BPE-002001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:part/fordata" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res2 http://${1}/v1/identify)
echo HTTP status: $RESULT
QQ=`cat Resources/trash/identify_res2`
echo json status: $QQ
if [ "$RESULT" == "400" ]; then
        if [[ "$QQ" =~ "BPE-002001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-002002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res3 -X GET http://${1}/v1/identify)
echo HTTP status: $RESULT
QW=`cat Resources/trash/identify_res3`
echo json status: $QW
if [ "$RESULT" == "400" ]; then
        if [[ "$QW" =~ "BPE-002002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-002003
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/broken_file.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res4 http://${1}/v1/identify)
echo HTTP status: $RESULT
QE=`cat Resources/trash/identify_res4`
echo json status: $QE
if [ "$RESULT" == "400" ]; then
        if [[ "$QE" =~ "BPE-002003" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002003 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-002005.sample
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=audio/pcm' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res5 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res5`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
        if [[ "$QR" =~ "BPE-002005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-002005.metadata
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=iage/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=image/jpeg' --output Resources/trash/identify_res6 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res6`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
        if [[ "$QR" =~ "BPE-002005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-002005.metadata_sample
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=audio/wav' -F 'metadata={"threshold": 0.3, "limit": 5};type=image/jpeg' --output Resources/trash/identify_res7 http://${1}/v1/identify)
echo HTTP status: $RESULT
QR=`cat Resources/trash/identify_res7`
echo json status: $QR
if [ "$RESULT" == "400" ]; then
        if [[ "$QR" =~ "BPE-002005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"eyJ0cmVzaG9sZCI6IDAuMywgImxpbWl0IjogNX0="};type=application/json' --output Resources/trash/identify_res8 http://${1}/v1/identify)
echo HTTP status: $RESULT
QT=`cat Resources/trash/identify_res8`
echo json status: $QT
if [ "$RESULT" == "400" ]; then
        if [[ "$QT" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5,};type=application/json' --output Resources/trash/identify_res9 http://${1}/v1/identify)
echo HTTP status: $RESULT
QT=`cat Resources/trash/identify_res9`
echo json status: $QT
if [ "$RESULT" == "400" ]; then
        if [[ "$QT" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_treshold
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"limit": 5};type=application/json' --output Resources/trash/identify_res10 http://${1}/v1/identify)
echo HTTP status: $RESULT
QY=`cat Resources/trash/identify_res10`
echo json status: $QY
if [ "$RESULT" == "400" ]; then
        if [[ "$QY" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_limit
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata={"threshold": 0.3};type=application/json' --output Resources/trash/identify_res11 http://${1}/v1/identify)
echo HTTP status: $RESULT
QY=`cat Resources/trash/identify_res11`
echo json status: $QY
if [ "$RESULT" == "400" ]; then
        if [[ "$QY" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-003001
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/empty.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res13 http://${1}/v1/identify)
echo HTTP status: $RESULT
QO=`cat Resources/trash/identify_res13`
echo json status: $QO
if [ "$RESULT" == "400" ]; then
        if [[ "$QO" =~ "BPE-003001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-003002
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/without_face.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res14 http://${1}/v1/identify)
echo HTTP status: $RESULT
QP=`cat Resources/trash/identify_res14`
echo json status: $QP
if [ "$RESULT" == "400" ]; then
        if [[ "$QP" =~ "BPE-003002" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003002 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-003003
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/more_then_one_face.jpg;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res15 http://${1}/v1/identify)
echo HTTP status: $RESULT
QA=`cat Resources/trash/identify_res15`
echo json status: $QA
if [ "$RESULT" == "400" ]; then
        if [[ "$QA" =~ "BPE-003003" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003003 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-003001.audio
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/sound.wav;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res16 http://${1}/v1/identify)
echo HTTP status: $RESULT
QOT=`cat Resources/trash/identify_res16`
echo json status: $QOT
if [ "$RESULT" == "400" ]; then
        if [[ "$QOT" =~ "BPE-003001" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-003001 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@;type=image/jpeg' -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res17 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTB=`cat Resources/trash/identify_res17`
echo json status: $QTB
if [ "$RESULT" == "400" ]; then
        if [[ "$QTB" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_photo
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'metadata={"threshold": 0.3, "limit": 5};type=application/json' --output Resources/trash/identify_res18 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTP=`cat Resources/trash/identify_res18`
echo json status: $QTP
if [ "$RESULT" == "400" ]; then
        if [[ "$QTP" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' -F 'metadata=;type=application/json' --output Resources/trash/identify_res19 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTQ=`cat Resources/trash/identify_res19`
echo json status: $QTQ
if [ "$RESULT" == "400" ]; then
        if [[ "$QTQ" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo identify.400.BPE-00502.no_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'photo=@Resources/photo.jpeg;type=image/jpeg' --output Resources/trash/identify_res20 http://${1}/v1/identify)
echo HTTP status: $RESULT
QTU=`cat Resources/trash/identify_res20`
echo json status: $QTU
if [ "$RESULT" == "400" ]; then
        if [[ "$QTU" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo delete.200
PREDATA=$(curl -s -w "%{http_code}" -H "Content-Type: multipart/form-data" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" -F 'template=@Resources/bio_template;type=application/octet-stream' -F 'metadata={"template_id":"12345"};type=application/json' --output Resources/trash/add_res1 http://${1}/v1/add)
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res1 http://${1}/v1/delete)
echo HTTP status: $RESULT
if [ "$RESULT" == "200" ]; then
echo "OK"
else
echo "FAIL"
fi
echo ;

echo delete.400.BPE-002404
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res8 http://${1}/v1/delete)
echo HTTP status: $RESULT
QSS=`cat Resources/trash/delete_res8`
echo json status: $QSS
if [ "$RESULT" == "400" ]; then
        if [[ "$QSS" =~ "BPE-002404" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002404 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo delete.400.BPE-002006
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"12345"}' --output Resources/trash/delete_res2 -X GET http://${1}/v1/delete)
echo HTTP status: $RESULT
QS=`cat Resources/trash/delete_res2`
echo json status: $QS
if [ "$RESULT" == "400" ]; then
        if [[ "$QS" =~ "BPE-002006" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-002006 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo delete.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"eyJ0ZW1wbGF0ZV9pZCI6IjEyMzQ1In0="}' --output Resources/trash/delete_res4 http://${1}/v1/delete)
echo HTTP status: $RESULT
QG=`cat Resources/trash/delete_res4`
echo json status: $QG
if [ "$RESULT" == "400" ]; then
        if [[ "$QG" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo delete.400.BPE-00005.bad_meta
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" -H "X-Request-ID: 4896c91b-9e61-3129-87b6-8aa299028058" --data '{"template_id":"01010101001010",}' --output Resources/trash/delete_res5 http://${1}/v1/delete)
echo HTTP status: $RESULT
QG=`cat Resources/trash/delete_res5`
echo json status: $QG
if [ "$RESULT" == "400" ]; then
        if [[ "$QG" =~ "BPE-00005" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00005 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;

echo delete.400.BPE-00502
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:application/json" -H "Expect:" --data 'metadata={}' --output Resources/trash/delete_res6 http://${1}/v1/delete)
echo HTTP status: $RESULT
QH=`cat Resources/trash/delete_res6`
echo json status: $QH
if [ "$RESULT" == "400" ]; then
        if [[ "$QH" =~ "BPE-00502" ]]; then
                echo "OK"
        else
                echo "FAIL (BPE-00502 is expected)"
        fi
else
        echo "FAIL (HTTP 400 is expected)"
fi
echo ;
