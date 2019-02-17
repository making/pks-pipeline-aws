#!/bin/bash
set -eo pipefail

ADMIN_SECRET=$(om credentials -p pivotal-container-service -c .properties.pks_uaa_management_admin_client -t json | jq -r .secret)
ADMIN_PASSWORD=$(om credentials -p pivotal-container-service -c .properties.uaa_admin_password -t json | jq -r .secret)

PKS_DOMAIN=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.pks_api_endpoint.value')

PKS_API_URL=https://${PKS_DOMAIN}:9021
UAA_URL=https://${PKS_DOMAIN}:8443

cat <<EOF
PKS_API_URL=${PKS_API_URL}
UAA_URL=${UAA_URL}
ADMIN_SECRET=${ADMIN_SECRET}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
PKS_USER=demo@example.com
PKS_PASSWORD=demodemo1234
CLUSTER_NAME=demo1

The following instruction shows how to create a cluster named "\${CLUSTER_NAME}"

### Log in to PKS as UAA admin

pks login -k -a \${PKS_API_URL} -u admin -p \${ADMIN_PASSWORD}

### Log in to PKS as a pks user

uaac target \${UAA_URL} --skip-ssl-validation
uaac token client get admin -s \${ADMIN_SECRET}
uaac user add \${PKS_USER} --emails \${PKS_USER} -p \${PKS_PASSWORD}
uaac member add pks.clusters.admin \${PKS_USER}

pks login -k -a \${PKS_API_URL} -u \${PKS_USER} -p \${PKS_PASSWORD}

### Create a PKS cluster

see https://github.com/making/pks-pipeline-aws/tree/master/terraform

Use the following terraform.tfvars

access_key="xxxxxxxxxxxxxxx"
secret_key="xxxxxxxxxxxxxxx"
region=$(cat $TF_DIR/terraform.tfstate | jq '.modules[0].outputs.region.value')
vpc_id=$(cat $TF_DIR/terraform.tfstate | jq '.modules[0].outputs.vpc_id.value')
elb_subnet_ids=$(cat $TF_DIR/terraform.tfstate | jq -r '.modules[0].outputs.public_subnets.value' | tr -d '\n')

EOF