#!/usr/bin/env bash

set -e -o pipefail  

rm -rf ./cluster.yaml

if [ -z "$ENVIRO" ]
then
      echo "\$var is empty, please set your environment"
      exit 1
else
      echo "\$ using environment $ENVIRO"
fi


export MASTER_VOL=$(cat ../terraform/terraform-$ENVIRO.tfvars | grep MASTER_VOL | cut -f2 -d"=" |  cut -d'"' -f2)
export NODE_VOL=$(cat ../terraform/terraform-$ENVIRO.tfvars | grep NODE_VOL | cut -f2 -d"=" |  cut -d'"' -f2)
export CIDR=$(cat ../terraform/terraform-$ENVIRO.tfvars | grep CIDR | cut -f2 -d"=" |  cut -d'"' -f2)

########### edit this according to your necessities ###########
export MASTER_SIZE="t2.medium"
export NODE_SIZE="t2.medium"
export MAX_PRICE="0.0250"
export K8S_VERSION="1.15.0"
export MIN_NODES="3"
export MAX_NODES="3"

###############################################################
export CLUSTER_TEMPLATE_YAML="cluster.tpl.yaml"
export CLUSTER_YAML=${CLUSTER_TEMPLATE_YAML%%.*}.yaml

###############################################################
export TF_OUTPUT=$(cd ../terraform && terraform output -json)
export REGION="$(echo ${TF_OUTPUT} | jq -r .region.value)"
export CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
export KOPS_STATE_STORE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_state_store.value)"
export VPC="$(echo ${TF_OUTPUT} | jq -r .vpc_id.value)"

aws ec2 modify-vpc-attribute --vpc-id ${VPC} --enable-dns-hostname "{\"Value\":true}"

envsubst < ${CLUSTER_TEMPLATE_YAML} > ${CLUSTER_YAML}

kops create -f ./$CLUSTER_YAML

kops create secret --name $CLUSTER_NAME sshpublickey admin -i ~/.ssh/id_rsa.pub 

sleep 5

kops update cluster $CLUSTER_NAME --yes






