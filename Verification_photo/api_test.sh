#!/usr/bin/env bash

echo health.200.0 
RESULT=$(curl http://${1}/pattern/health)
echo $RESULT
if [[ $RESULT =~ "0" ]];
then
echo "OK"
else
echo "FAIL"
fi
echo ;


echo extract.200.JPG
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/photo.jpg --output Resources/bio_template http://${1}/pattern/extract)
echo HTTP status: $RESULT
PLM=`du -b Resources/bio_template`
echo Size and name of template: $PLM 
if [ "$RESULT" == "200" ]; then
	if [[ "$PLM" == *[1-9]* ]]; then
		echo "OK"
	else
		echo "FAIL (HTTP 200, but template is empty)"
	fi
else
	echo "FAIL"
fi
echo ;


echo extract.200.PNG
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/png" -H "Expect:" --data-binary @Resources/photo.png --output Resources/template/bio_template_a http://${1}/pattern/extract)
echo HTTP status: $RESULT
PLO=`du -b Resources/template/bio_template_a`
echo Size and name of template: $PLO
if [ "$RESULT" == "200" ]; then
	if [[ "$PLO" == *[1-9]* ]]; then
		echo "OK"
	else
	echo "FAIL (HTTP 200, but template is empty"
	fi
else
echo "FAIL"
fi
echo ;


echo extract.content-type.lowercase.image/png with JPG 
RESULT=$(curl -s -w "%{http_code}" -H "content-type:image/png" -H "Expect:" --data-binary @Resources/photo.jpg --output Resources/template/bio_template_d http://${1}/pattern/extract)
echo HTTP status: $RESULT
NHC=`du -b Resources/template/bio_template_d`
echo Size and name of template: $NHC
if [ "$RESULT" == "200" ]; then
	if [[ "$NHC" == *[1-9]* ]]; then
		echo "OK"
	else
	echo "FAIL (HTTP 200, but template is empty"
	fi
else
	echo "FAIL (we ask you not to check jpg or png, just image)"
fi
echo ;


echo extract.content-type.lowercase.image/jpeg with PNG
RESULT=$(curl -s -w "%{http_code}" -H "content-type:image/jpeg" -H "Expect:" --data-binary @Resources/photo.png --output Resources/template/bio_template_e http://${1}/pattern/extract)
echo HTTP status: $RESULT
RQM=`du -b Resources/template/bio_template_e`
echo Size and name of template: $RQM
if [ "$RESULT" == "200" ]; then
	if [[ "$RQM" == *[1-9]* ]]; then
		echo "OK"
	else
		echo "FAIL (HTTP 200, but template is empty)"
	fi
else
	echo "FAIL (we ask you not to check jpg or png, just image)"
fi
echo ;


echo extract.400.BPE-002003.empty_file
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/empty.jpg --output Resources/trash/bio_template_a http://${1}/pattern/extract)
echo HTTP status: $RESULT
PP=`cat Resources/trash/bio_template_a`
echo json status: $PP
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$PP" =~ "BPE-002003" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002003 is expected)"
fi
echo ;


echo extract.400.BPE-003002.no_face 
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/24.jpg --output Resources/trash/bio_template_b http://${1}/pattern/extract)
echo HTTP status: $RESULT
II=`cat Resources/trash/bio_template_b`
echo json status: $II
if [[ "$RESULT" =~ "400" ]]; 
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$II" =~ "BPE-003002" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-003002 is expected)"
fi
echo ;


echo extract.400.BPE-003003.more_than_one_face
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/two_face.jpg --output Resources/trash/bio_template_c http://${1}/pattern/extract)
echo HTTP status: $RESULT
YY=`cat Resources/trash/bio_template_c`
echo json status: $YY
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$YY" =~ "BPE-003003" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-003003 is expected)"
fi
echo ;


echo extract.400.BPE-002001.wrong_content-type
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:multipart/form-data" -H "Expect:" --data-binary @Resources/photo.jpg --output Resources/trash/bio_template_d http://${1}/pattern/extract)
echo HTTP status: $RESULT
QQ=`cat Resources/trash/bio_template_d`
echo json status: $QQ
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$QQ" =~ "BPE-002001" ]];
then 
	echo "OK"
else
	echo "FAIL (BPE-002001 is expected)"
fi
echo ;


echo extract.400.BPE-002002.invalid_http_method
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" -H "Expect:" --data-binary @Resources/photo.jpg --output Resources/trash/bio_template_e -X GET http://${1}/pattern/extract)
echo HTTP status: $RESULT
WW=`cat Resources/trash/bio_template_e`
echo json status: $WW
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$WW" =~ "BPE-002002" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002002 is expected)"
fi
echo ;


echo extract.400.BPE-002003.sound
RESULT=$(curl -s -w "%{http_code}" -H "Content-Type:image/jpeg" --data-binary @Resources/sound.wav --output Resources/trash/bio_template_z http://${1}/pattern/extract)
echo HTTP status: $RESULT
BV=`cat Resources/trash/bio_template_z`
echo json status: $BV 
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$BV" =~ "BPE-002003" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002003 is expected)"
fi
echo ;


echo compare.400.BPE-002001.incorrect_content-type
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/bio_template;type=application/octet-stream" --output Resources/trash/bio_template_f -X POST http://${1}/pattern/compare) 
echo HTTP status: $RESULT
BB=`cat Resources/trash/bio_template_f`
echo json status: $BB
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$BB" =~ "BPE-002001" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002001 is expected)"
fi
echo ;


echo compare.200 
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -X POST http://${1}/pattern/compare)
MMM=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -X POST http://${1}/pattern/compare| sed 's/....$//' | sed "s/[^.]*\.//")
echo $RESULT
if [[ "$RESULT" =~ "200" ]]; then
	if [[ "$RESULT" =~ "." ]]; then
		if [[ "$MMM" == *[0-9]* ]]; then
			echo "OK"
		else 
			echo "FAIL (score format double is expected)"
		fi 
	else
	echo "FAIL (score format double is expected)"
	fi
else
	echo "FAIL"	
fi
echo ;


echo compare.400.BPE-002004.empty_bio_feature
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template_empty;type=application/octet-stream" -F "bio_template=@Resources/bio_template;type=application/octet-stream" --output Resources/trash/bio_template_j -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_j`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002004 is expected)"
fi
echo ;


echo compare.400.BPE-002004.empty_bio_template
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" --output Resources/trash/bio_template_j -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_j`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002004 is expected)"
fi
echo ;


echo compare.400.BPE-002004.empty
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template_empty;type=application/octet-stream" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" --output Resources/trash/bio_template_j -X POST http://${1}/pattern/compare)
echo HTTP status: $RESULT
GG=`cat Resources/trash/bio_template_j`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$GG" =~ "BPE-002004" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002004 is expected)"
fi
echo ;


echo compare.400.BPE-002002.invalid_http_method
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/bio_template;type=application/octet-stream" --output Resources/trash/bio_template_x -X GET http://${1}/pattern/compare)
echo HTTP status: $RESULT
XP=`cat trash/bio_template_x`
echo json status: $GG
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$XP" =~ "BPE-002002" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002002 is expected)"
fi
echo ;

echo compare.400.BPE-002004.bio_template_0X00
RESULT=$(curl -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_feature=@Resources/bio_template;type=application/octet-stream" -F "bio_template=@Resources/tem;type=application/octet-stream" --output Resources/trash/bio_template_UI http://${1}/pattern/compare)
echo HTTP status: $RESULT
JJJ=`cat Resources/trash/bio_template_UI`
echo json status: $JJJ
if [[ "$RESULT" =~ "400" ]];then
	if [[ "$JJJ" =~ "BPE-002004" ]];then
		echo "Error code is correct"
	else
		echo "FAIL (BPE-002004 is expected)"
	fi
	echo "OK"
else
	echo "FAIL"
fi
echo ;


echo verify.400.invalid_http_method
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/bio_template_q -X GET http://${1}/pattern/verify)
echo HTTP status: $RESULT
BF=`cat Resources/trash/bio_template_q`
echo json status: $BF
if [[ "$RESULT" =~ "400" ]] && [[ "$BF" =~ "BPE-002002" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$BF" =~ "BPE-002002" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002002 is expected)"
fi
echo ;


echo verify.400.BPE-002001.incorrect_content-type
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:image/jpeg" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/bio_template_i http://${1}/pattern/verify)
echo HTTP status: $RESULT
UI=`cat Resources/trash/bio_template_i`
echo json status: $UI
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$UI" =~ "BPE-002001" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002001 is expected)"
fi
echo ;


echo verify.400.BPE-002003.empty_file
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/empty.jpg;type=image/jpeg" --output Resources/trash/bio_template_g http://${1}/pattern/verify)
echo HTTP status: $RESULT
IO=`cat Resources/trash/bio_template_g`
echo json status: $IO
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$IO" =~ "BPE-002003" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002003 is expected)"
fi
echo ;


echo verify.400.BPE-002004.empty_template
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" -F "sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/bio_template_k http://${1}/pattern/verify)
echo HTTP status: $RESULT
NH=`cat Resources/trash/bio_template_k`
echo json status: $NH
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$NH" =~ "BPE-002004" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002004 is expected)"
fi
echo ;


echo verify.400.BPE-002003.empty_photo 
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template_empty;type=application/octet-stream" -F "sample=@Resources/empty.jpg;type=image/jpeg" --output Resources/trash/bio_template_k http://${1}/pattern/verify)
echo HTTP status: $RESULT
NH=`cat Resources/trash/bio_template_k`
echo json status: $NH
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$NH" =~ "BPE-002003" ]] || [[ "$NH" =~ "BPE-002004" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-002004 or BPE-002003 is expected)"
fi
echo ;


echo verify.400.BPE-003002.no_face
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/24.jpg;type=image/jpeg" --output Resources/trash/bio_template_l http://${1}/pattern/verify)
echo HTTP status: $RESULT
GT=`cat Resources/trash/bio_template_l`
echo json status: $GT
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$GT" =~ "BPE-003002" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-003002 is expected)"
fi
echo ;


echo verify.400.BPE-003003.more_than_one_face
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/two_face.jpg;type=image/jpeg" --output Resources/trash/bio_template_m http://${1}/pattern/verify)
echo HTTP status: $RESULT
HJ=`cat Resources/trash/bio_template_m`
echo json status: $HJ
if [[ "$RESULT" =~ "400" ]];
then
	echo "HTTP code is correct"
else
	echo "FAIL (HTTP code 400 is expected)"
fi
if [[ "$HJ" =~ "BPE-003003" ]];
then
	echo "OK"
else
	echo "FAIL (BPE-003003 is expected)"
fi
echo ;


echo verify.400.BPE-002005.invalid_content-type_multipart
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/photo.jpg;type=application/octet-stream" --output Resources/trash/bio_template_qs -X POST http://${1}/pattern/verify)
echo HTTP status: $RESULT
BFW=`cat Resources/trash/bio_template_qs`
echo json status: $BFW
if [[ "$RESULT" =~ "400" ]]; then
        if [[ "$BFW" =~ "BPE-002005" ]]; then
                if [[ "$BFW" =~ "multiparted" ]]; then
                        echo "OK"
                else
			echo "FAIL (invalid message)"
                fi
        else
        echo "FAIL (BPE-002005 is expected)"
        fi
else
echo "FAIL"
fi
echo ;


echo verify.200
#RTY=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@bio_template;type=application/octet-stream" -F "sample=@photo.jpg;type=image/jpeg" --output trash/bio_template_good_2  http://${1}/pattern/verify)
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Content-type:multipart/form-data" -F "bio_template=@Resources/bio_template;type=application/octet-stream" -F "sample=@Resources/photo.jpg;type=image/jpeg" --output Resources/trash/bio_template_good_1  http://${1}/pattern/verify)
RTY=`cat Resources/trash/bio_template_good_1 | grep -a score`
RUI=`cat Resources/trash/bio_template_good_1 | grep -a score | sed "s/[^.]*\.//"`
TVZ=`cat Resources/trash/bio_template_good_1 | tail -n 2 Resources/trash/bio_template_good_1 > Resources/trash/ver_template` 
XRT=`head -1 Resources/trash/ver_template > Resources/trash/ll`
DDDD=`du -b Resources/trash/ll`
echo HTTP status: $RESULT
echo Size and name of response $DDDD
if [ "$RESULT" == "200" ]; then
	if [[ "$RTY" =~ "." ]]; then
		if [[ "$RUI" == *[0-9]* ]]; then
			if [[ "$DDDD" == *[1-9]* ]]; then
			echo "OK"
			else
				echo "FAIL (score format double is expected)"
			fi
		else
			echo "FAIL (score format double is expected)"
		fi
	else
		echo "FAIL (score format double is expected)"
	fi
else
echo "FAIL"
fi
echo ;

echo verify.200.boundary_no_hyphens
cat Resources/file1_3 > Resources/final_body2
cat Resources/bio_template >> Resources/final_body2
cat Resources/file2_3 >> Resources/final_body2
cat Resources/photo.jpg >> Resources/final_body2
cat Resources/file3_3 >> Resources/final_body2
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @Resources/final_body2 --output Resources/trash/bio_template_good_2  http://${1}/pattern/verify)
RTY=`cat Resources/trash/bio_template_good_2 | grep -a score`
RUI=`cat Resources/trash/bio_template_good_2 | grep -a score | sed "s/[^.]*\.//"`
TVZ=`cat Resources/trash/bio_template_good_2 | tail -n 2 Resources/trash/bio_template_good_2 > trash/ver_template2`
XRT=`head -1 Resources/trash/ver_template2 > Resources/trash/ll2`
DDDD=`du -b Resources/trash/ll2`
echo HTTP status: $RESULT
echo Size and name of response $DDDD
if [ "$RESULT" == "200" ]; then
        if [[ "$RTY" =~ "." ]]; then
                if [[ "$RUI" == *[0-9]* ]]; then
                        if [[ "$DDDD" == *[1-9]* ]]; then
                        echo "OK"
                        else
				echo "FAIL (score format double is expected)"
                        fi
                else
			echo "FAIL (score format double is expected)"
                fi
        else
		echo "FAIL (score format double is expected)"
        fi
else
echo "FAIL"
fi
echo ;


echo verify.200.no_filename
cat Resources/file1_4 > Resources/final_body3
cat Resources/bio_template >> Resources/final_body3
cat Resources/file2_4 >> Resources/final_body3
cat Resources/photo.jpg >> Resources/final_body3
cat Resources/file3_4 >> Resources/final_body3
RESULT=$(curl --max-time 15000 -s -w "%{http_code}" -H "Expect:" -H "Content-type:multipart/form-data; boundary=72468" --data-binary @Resources/final_body3 --output Resources/trash/bio_template_good_3  http://${1}/pattern/verify)
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
                        echo "OK"
                        else
				echo "FAIL (score format double is expected)"
                        fi
                else
			echo "FAIL (score format double is expected)"
                fi
        else
		echo "FAIL (score format double is expected)"
        fi
else
echo "FAIL"
fi
