#!/usr/bin/env bash

set -e -o pipefail  

if [ -z ${ENVIRO} ]; 
then 
    echo "var ENVIRO is unset "
    exit 0
else 
    echo " creating for $ENVIRO environment..."
fi

export DOMAIN=$(cat terraform-$ENVIRO.tfvars | grep DOMAIN | cut -f2 -d"=" |  cut -d'"' -f2)
export REGION=$(cat terraform-$ENVIRO.tfvars | grep REGION | cut -f2 -d"=" |  cut -d'"' -f2)
export VPC_NAME=$(cat ../../terraform/terraform-prod.tfvars | grep VPC_NAME | cut -f2 -d"=" | cut -d'"' -f2)
export VPC=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[].{id:VpcId}' --output text)

# terraform state 
aws s3 mb s3://terraform-state-${DOMAIN} --region ${REGION}

#init terraform
terraform init -backend-config "bucket=terraform-state-$DOMAIN" -backend-config "dynamodb_table=terraform-lock" -backend-config "region=$REGION" -backend-config "key=terraform"