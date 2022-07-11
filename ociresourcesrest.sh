#!/bin/bash

LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"

####################################################################################
REGIONS=()
REGIONS+=('eu-marseille-1')
#REGIONS+=('eu-frankfurt-1')
#REGIONS+=('eu-amsterdam-1')
#REGIONS+=('af-johannesburg-1')
#REGIONS+=('eu-amsterdam-1')
#REGIONS+=('eu-stockholm-1')
#REGIONS+=('me-abudhabi-1')
#REGIONS+=('ap-mumbai-1')
#REGIONS+=('eu-paris-1')
#REGIONS+=('uk-cardiff-1')
#REGIONS+=('me-dubai-1')
#REGIONS+=('eu-frankfurt-1')
#REGIONS+=('sa-saopaulo-1')
#REGIONS+=('ap-hyderabad-1')
#REGIONS+=('us-ashburn-1')
#REGIONS+=('ap-seoul-1')
#REGIONS+=('me-jeddah-1')
#REGIONS+=('af-johannesburg-1')
#REGIONS+=('ap-osaka-1')
#REGIONS+=('uk-london-1')
#REGIONS+=('eu-milan-1')
#REGIONS+=('eu-madrid-1')
#REGIONS+=('ap-melbourne-1')
#REGIONS+=('il-jerusalem-1')
#REGIONS+=('ap-tokyo-1')
#REGIONS+=('us-phoenix-1')
#REGIONS+=('mx-queretaro-1')
#REGIONS+=('sa-santiago-1')
#REGIONS+=('ap-singapore-1')
#REGIONS+=('us-sanjose-1')
#REGIONS+=('ap-sydney-1')
#REGIONS+=('sa-vinhedo-1')
#REGIONS+=('ap-chuncheon-1')
#REGIONS+=('ca-montreal-1')
#REGIONS+=('ca-toronto-1')
#REGIONS+=('eu-zurich-1')

SERVICE_TYPES=()
SERVICE_TYPES+=('Instance')
########################## Fill these in with your values ##########################
#OCID of the tenancy calls are being made in to
tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaahrs4avamaxiscouyeoirc7hz5byvumwyvjedslpsdb2d2xe2kp2q"

# OCID of the user making the rest call
user_ocid="ocid1.user.oc1..aaaaaaaae4iep5wzdfqboxws6mlubt4rssygmmu7oek6qq2di7lgyzlqk5sq"

# path to the private PEM format key for this user
privateKeyPath="/home/runner/.oci/api_key.pem"
#privateKeyPath="/mnt/c/Travail/Travail2019/Demos/InfraAsCode/DevOpsDb/SshKeys/APIKeys/bmcs_api_key.pem"

# fingerprint of the private key for this user
fingerprint="4f:90:09:d7:2a:ea:81:a8:76:97:2a:51:9c:e9:36:03"

####################################################################################
INSTANCE_TOTAL=0
OCPU_TOTAL=0
MEM_TOTAL=0
for region in "${REGIONS[@]}"; do
  echo -e "##### Region $region"
  # The host you want to make the call against
  host="query.$region.oci.oraclecloud.com"
  # The REST api you want to call, with any required paramters.
  #rest_api="/20160918/instances?compartmentId=ocid1.compartment.oc1..aaaaaaaaubpk66xo3sw3bbqdhzhklvsruxk2pnlzfmnkkp4xmi2vwd52wzlq"
  rest_api="/20180409/resources"

  # the body of the put request
  #body="./request.json"
  body="{\"type\": \"Structured\", \"query\": \"query instance resources where lifeCycleState != 'TERMINATED' && lifeCycleState != 'FAILED'\"}"
  
  
  # extra headers required for a POST/PUT request
  body_arg=(--data-binary ${body})
  content_sha256="$(echo $body | openssl dgst -binary -sha256 | openssl enc -e -base64)";
  content_sha256_header="x-content-sha256: $content_sha256"
  content_length="$(echo $body | wc -c | xargs)";
  content_length_header="content-length: $content_length"
  headers="(request-target) date host"
  # add on the extra fields required for a POST/PUT
  headers=$headers" x-content-sha256 content-type content-length"
  content_type_header="content-type: application/json";
  
  date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
  date_header="date: $date"
  host_header="host: $host"
  request_target="(request-target): post $rest_api"
  # note the order of items. The order in the signing_string matches the order in the headers, including the extra POST fields
  signing_string="$request_target\n$date_header\n$host_header"
  # add on the extra fields required for a POST/PUT
  signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"
  
  #echo "====================================================================================================="
  #printf '%b' "signing string is $signing_string \n"
  signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
  #printf '%b' "Signed Request is  \n$signature\n"
  
  #echo "====================================================================================================="
  #set -x
  INSTANCE_LIST=$(echo -e ${body} | curl -X POST --data-binary @- -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" | jq --raw-output '.items[].identifier')
  INSTANCE_NO=0
  REGION_OCPUS=0
  REGION_MEM=0
  for element in $INSTANCE_LIST; do
    INSTANCE_NO=$((INSTANCE_NO+1))
    INSTANCE_TOTAL=$((INSTANCE_TOTAL+1))
    # The host you want to make the call against
    host="iaas.$region.oci.oraclecloud.com"
    # The REST api you want to call, with any required paramters.
    rest_api="/20160918/instances/${element}"

    date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
    date_header="date: $date"
    host_header="host: $host"
    request_target="(request-target): get $rest_api"
    # note the order of items. The order in the signing_string matches the order in the headers
    signing_string="$request_target\n$date_header\n$host_header"
    headers="(request-target) date host"

    signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`

    JSON_OUTPUT=$(curl -X GET -sS https://$host$rest_api -H "date: $date" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"")
    #echo $JSON_OUTPUT | jq; exit
    OCPUS=$(echo $JSON_OUTPUT | jq --raw-output '.shapeConfig.ocpus')
    MEM=$(echo $JSON_OUTPUT | jq --raw-output '.shapeConfig.memoryInGBs')
    REGION_OCPUS=$((REGION_OCPUS+$OCPUS))
    REGION_MEM=$((REGION_MEM+$MEM))
    printf '%s %5d %5d %6d\n' "${element}" "${INSTANCE_NO}" "${OCPUS}" "${MEM}"
  done
  printf '### REGION INSTANCES = %d, REGION OCPUS = %d, REGION MEMORY = %dGB\n\n' "${INSTANCE_NO}" "${REGION_OCPUS}" "${REGION_MEM}"
  OCPU_TOTAL=$((OCPU_TOTAL+$REGION_OCPUS))
  MEM_TOTAL=$((MEM_TOTAL+$REGION_MEM))
done
printf '### TENANCY INSTANCES = %d, TENANCY OCPUS = %d, TENANCY MEMORY = %dGB\n' "${INSTANCE_TOTAL}" "${OCPU_TOTAL}" "${MEM_TOTAL}"
echo "::set-output name=cpu::${OCPU_TOTAL}"
echo "::set-output name=mem::${MEM_TOTAL}"
echo "::set-output name=nbinst::${INSTANCE_TOTAL}"
