#!/bin/bash
#
# have a look at:
# https://github.com/oracle/oci-cli/blob/master/services/resource_search/examples_and_test_scripts/resource_search_example.sh

# all resource types
# oci search resource-type list --all | jq --raw-output '.data[].name'

# oci --profile BMWPOC search resource structured-search --query-text "QUERY instance resources where lifeCycleState != 'TERMINATED' && lifeCycleState != 'FAILED'" --query 'data.items[*].{name:"display-name",resource:"resource-type",compartment:"compartment-id"}' --output table

#OCIPROFILE="${OCIPROFILE:="BMWPOC"}"
OCIPROFILE="${OCIPROFILE:="DEFAULT"}"

#if [ $# -lt 1 ]; then
 # echo "illegal number of parameters"
  #exit
#fi

REGIONS=()
#REGIONS+=($*)
#REGIONS+=('eu-frankfurt-1')
REGIONS+=('eu-marseille-1')
#REGIONS+=('eu-amsterdam-1')
#REGIONS+=('af-johannesburg-1')

SERVICE_TYPES=()
SERVICE_TYPES+=('Instance')
#SERVICE_TYPES+=('Vcn')
#SERVICE_TYPES+=('CloudExadataInfrastructure')
#SERVICE_TYPES+=('AutonomousDatabase')

PROXY_SERVER=www-proxy-ams.nl.oracle.com

# setup oci cli
# source ~/tmp/oracle-cli/bin/activate || exit
# do not change value if set in environment
DEBUG_PRINT="${DEBUG_PRINT:=false}"

debug_print()
{
  if [ "${DEBUG_PRINT}" = true ]; then
    echo -e "$1"
  fi
}

if ping -c 1 ${PROXY_SERVER}  &> /dev/null; then
    debug_print "$PROXY_SERVER is reachable";
    export http_proxy="http://${PROXY_SERVER}:80"
    export https_proxy="http://${PROXY_SERVER}:80"
    export HTTP_PROXY="http://${PROXY_SERVER}:80"
    export HTTPS_PROXY="http://${PROXY_SERVER}:80"
    debug_print " http_proxy = ${http_proxy}"
    debug_print "https_proxy = ${https_proxy}"
    debug_print " HTTP_PROXY = ${http_proxy}"
    debug_print "HTTPS_PROXY = ${https_proxy}"
else
    debug_print "$PROXY_SERVER is NOT reachable";
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
fi

TENANCY_OCPUS=0
TENANCY_MEMORY=0
TENANCY_INSTANCE_COUNT=0
for region in "${REGIONS[@]}"; do
  echo -e "##### Region $region"
  REGION_OCPUS=0
  REGION_MEMORY=0
  REGION_INSTANCE_COUNT=0
  for type in "${SERVICE_TYPES[@]}"; do
    echo "### Service Type $type"
    query_text="query $type resources where lifeCycleState != 'TERMINATED' && lifeCycleState != 'FAILED'"
      thequery='data.items[*].{name:"display-name",resource:"resource-type",ocid:"identifier",state:"lifecycle-state"}'
    #oci --profile "${OCIPROFILE}" --region $region search resource structured-search --query-text "${query_text}" | jq -r '[.data.items[] | {displayName:."display-name" , compartment: ."compartment-id", resourceType: ."resource-type"}]'
    LIST=$(oci --profile "${OCIPROFILE}" --region $region search resource structured-search --query-text "${query_text}" | jq -r '.data.items[].identifier')
    for element in $LIST; do
      JSON=$(oci --profile "${OCIPROFILE}" --region $region compute instance get --instance-id "${element}")
      OCPUS=$(echo $JSON| jq -r '.data."shape-config"."ocpus"')
      REGION_OCPUS=$((REGION_OCPUS+$OCPUS))
      MEMORY=$(echo $JSON| jq -r '.data."shape-config"."memory-in-gbs"')
      REGION_MEMORY=$((REGION_MEMORY+$MEMORY))
      REGION_INSTANCE_COUNT=$((REGION_INSTANCE_COUNT+1))
      printf '%s %5d %5d %6d\n' "${element}" "${REGION_INSTANCE_COUNT}" "${OCPUS}" "${MEMORY}"
    done
    #oci --profile "${OCIPROFILE}" --region $region search resource structured-search --query-text "${query_text}" --query "${thequery}" --output table
  done
  printf '### REGION INSTANCES = %d, REGION OCPUS = %d, REGION MEMORY = %dGB\n\n' "${REGION_INSTANCE_COUNT}" "${REGION_OCPUS}" "${REGION_MEMORY}"
  TENANCY_OCPUS=$((TENANCY_OCPUS+$REGION_OCPUS))
  TENANCY_MEMORY=$((TENANCY_MEMORY+$REGION_MEMORY))
  TENANCY_INSTANCE_COUNT=$((TENANCY_INSTANCE_COUNT+$REGION_INSTANCE_COUNT))
done
printf '### TENANCY INSTANCES = %d, TENANCY OCPUS = %d, TENANCY MEMORY = %dGB\n' "${TENANCY_INSTANCE_COUNT}" "${TENANCY_OCPUS}" "${TENANCY_MEMORY}"
echo "::set-output name=cpu::${TENANCY_OCPUS}"
echo "::set-output name=mem::${TENANCY_MEMORY}"
echo "::set-output name=nbinst::${TENANCY_INSTANCE_COUNT}"

