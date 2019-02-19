#!/bin/bash
set -eo pipefail

export PKS_API_IP=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.pks_api_elb_dns_name.value')
export PKS_DOMAIN=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.pks_api_endpoint.value')
export PKS_MAIN_NETWORK_NAME=pks-main
export PKS_SERVICES_NETWORK_NAME=pks-services
export SINGLETON_AVAILABILITY_ZONE=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.azs.value[0]')
export AVAILABILITY_ZONES=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.azs.value | map({name: .})' | tr -d '\n' | tr -d '"')
export AVAILABILITY_ZONE_NAMES=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.azs.value' | tr -d '\n' | tr -d '"')
if [ "${CERT_PEM}" == "" ];then
	WILDCARD_DOMAIN=`echo ${OM_TARGET} | sed 's/pcf/*/g'`
	CERTIFICATES=`om generate-certificate -d ${WILDCARD_DOMAIN}`
	CERT_PEM=`echo $CERTIFICATES | jq -r '.certificate'`
	KEY_PEM=`echo $CERTIFICATES | jq -r '.key'`
fi
export CERT_PEM=`cat <<EOF | sed 's/^/  /'
${CERT_PEM}
EOF
`
export KEY_PEM=`cat <<EOF | sed 's/^/  /'
${KEY_PEM}
EOF
`
export INSTANCE_PROFILE_MASTER=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.pks_master_iam_instance_profile_name.value')
export INSTANCE_PROFILE_WORKER=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.pks_worker_iam_instance_profile_name.value')
export API_HOSTNAME=${PKS_DOMAIN}
export UAA_URL=${PKS_DOMAIN}

cat <<EOF > vars.yml
cert_pem: |
${CERT_PEM}
key_pem: |
${KEY_PEM}
api_hostname: ${API_HOSTNAME}
availability_zone_names: ${AVAILABILITY_ZONE_NAMES}
instance_profile_master: ${INSTANCE_PROFILE_MASTER}
instance_profile_worker: ${INSTANCE_PROFILE_WORKER}
pks_main_network_name: ${PKS_MAIN_NETWORK_NAME}
pks_services_network_name: ${PKS_SERVICES_NETWORK_NAME}
availability_zones: ${AVAILABILITY_ZONES}
singleton_availability_zone: ${SINGLETON_AVAILABILITY_ZONE}
addons_spec: |
$(cat <(for f in `ls ${ADDONS_DIR}/*.yml`;do cat $f;echo;echo "---";done) | sed 's/^/  /')
EOF