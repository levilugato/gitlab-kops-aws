#!/usr/bin/env bash

set -e -o pipefail  

export DOMAIN=$(cat terraform-$ENVIRO.tfvars | grep DOMAIN | cut -f2 -d"=" |  cut -d'"' -f2)
export REGION=$(cat terraform-$ENVIRO.tfvars | grep REGION | cut -f2 -d"=" |  cut -d'"' -f2)

aws s3 mb s3://terraform-state-${DOMAIN} --region ${REGION}

aws dynamodb create-table \
	--region "${REGION}" \
	--table-name terraform-lock \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 

terraform init -backend-config "bucket=terraform-state-$DOMAIN" -backend-config "dynamodb_table=terraform-lock" -backend-config "region=$REGION" -backend-config "key=terraform"
















