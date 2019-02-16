#!/bin/bash
set -eo pipefail 

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