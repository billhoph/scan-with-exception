#image='harbor.alson.space/demo/sample-app:v1.3'
#user='xxxxxxxxxx-xxxxxx-xxxxxxx'
#password='xxxxxxxxxxxxxxxx'
#cwp_url='https://asia-northeast1.cloud.twistlock.com/japan-1167259786'

cwp_url=$1
user=$2
password=$3
image=$4

generate_post_data()
{
  cat <<EOF
{
  "username": "$user",
  "password": "$password"
}
EOF
}

result_url=$(./twistcli images scan --address $cwp_url --user $user --password $password $image | tail -1 | cut -c 33-)
image_id=${result_url: -73}

login=$(curl --silent \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$(generate_post_data)" \
  $cwp_url/api/v22.12/authenticate)

token=$(echo $login|jq .token)
token=${token:1:-1}

pcs_url="https://asia-northeast1.cloud.twistlock.com/japan-1167259786/api/v1/scans?limit=17&offset=0&project=Central+Console&reverse=true&search=$image_id&sort=entityInfo.vulnerabilityRiskScore&type=ciImage,ciTas"

scan_result=$(curl --silent -o response.json -H "Authorization: Bearer $token" -X GET $pcs_url)
python3 scan-result.py

echo 
echo "-----Please refer to the following links for more detail information-----"
echo $result_url
