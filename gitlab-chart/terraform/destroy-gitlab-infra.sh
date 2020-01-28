#!/usr/bin/env bash

set -e -o pipefail  

export VPC_NAME=$(cat ../../terraform/terraform-prod.tfvars | grep VPC_NAME | cut -f2 -d"=" | cut -d'"' -f2)
export VPC=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[].{id:VpcId}' --output text)

terraform destroy -var-file=terraform-$ENVIRO.tfvars -var VPC=$VPC -var ENVIRO=$ENVIRO