#image='harbor.alson.space/demo/sample-app:v1.3'
image=$1
user='1761693e-e8a7-48b2-953f-a68dc442c9f1'
password='BJP5MWXm+aAe/WOaoyrVAiBAGiM='
cwp_url='https://asia-northeast1.cloud.twistlock.com/japan-1167259786'

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

login=$(curl \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$(generate_post_data)" \
  $cwp_url/api/v22.12/authenticate)

token=$(echo $login|jq .token)
token=${token:1:-1}

pcs_url="https://asia-northeast1.cloud.twistlock.com/japan-1167259786/api/v1/scans?limit=17&offset=0&project=Central+Console&reverse=true&search=$image_id&sort=entityInfo.vulnerabilityRiskScore&type=ciImage,ciTas"

scan_result=$(curl -o response.json -H "Authorization: Bearer $token" -X GET $pcs_url)
python3 scan-result.py
