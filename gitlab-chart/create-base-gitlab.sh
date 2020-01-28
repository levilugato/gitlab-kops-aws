#!/usr/bin/env bash

set -e -o pipefail

if [ -z ${ENVIRO} ]; 
then 
    echo "var ENVIRO is unset "
    exit 0
else 
    echo " creating for $ENVIRO environment..."
fi

export REGION=$(cat ./terraform/terraform-$ENVIRO.tfvars | grep REGION | cut -f2 -d"=" |  cut -d'"' -f2)
export COMPANHY=$(cat ./terraform/terraform-$ENVIRO.tfvars | grep DOMAIN | cut -f2 -d"=" |  cut -d'"' -f2)
export NS=$ENVIRO-gitlab

read -p "do you wish create Buckets ? :  " RES

if [[ "$RES" == "yes"  ]]
then
	# buckets for Gitlab
    aws s3 mb s3://gitlab-registry-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-lfs-storage-$COMPANHY-$ENVIRO --region ${REGION}   
    aws s3 mb s3://gitlab-artifacts-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-uploads-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-externaldiffs-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-pseudonymizer-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-backup-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-tmp-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-packages-storage-$COMPANHY-$ENVIRO --region ${REGION}
    aws s3 mb s3://gitlab-runner-cache-$COMPANHY-$ENVIRO --region ${REGION}
else
	echo "Buckets already created"
fi

#Create Namespace
kubectl create namespace $NS

#Create secret for registry storage
kubectl create secret generic registry-storage --from-file=config=registry-storage.yaml -n $NS

# Create secret for global settings
kubectl create secret generic gitlab-bucket-config --from-file=config=rails.s3.yaml -n $NS

#Create secret for backup bucket 
kubectl create secret generic storage-config --from-file=config=storage.config -n $NS

#Create Password secret for Gitlab RDS
kubectl create secret generic gitlab-postgresql-password --from-literal=postgres-password="yourdbpass" -n $NS

#Create Password for SMTP
kubectl create secret generic smtp-pass --from-literal=smtp-pass="yoursmtpservicepass" -n $NS




