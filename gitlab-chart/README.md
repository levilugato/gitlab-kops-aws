## Requirements

* kubectl
* terraform 0.12
* aws
* helm v3
* jq

## Usage

From `terrafom` path, run the Terraform commands to create an `RDS DB` and an `Elasticache Redis Instance` for gitlab chart : 

Run this script once (only first time) to create the state bucket :

    ./init-terraform.sh 
 

Then Run the script once (only first time) you need to create some environment (choose `staging` or `prod`) 

    export ENVIRO="yourenviro"
    
    terraform workspace select $ENVIRO

    terraform plan -var-file=terraform-$ENVIRO.tfvars -var=VPC=$VPC -var=ENVIRO=$ENVIRO

    terraform apply -var-file=terraform-$ENVIRO.tfvars -var=VPC=$VPC -var=ENVIRO=$ENVIRO


If the one of the environment(choose `staging` or `prod`) it's already created, run :

    export ENVIRO="yourenviro" 

    terraform workspace select $ENVIRO

    export VPC_NAME=$(cat ../../terraform/terraform-prod.tfvars | grep VPC_NAME | cut -f2 -d"=" | cut -d'"' -f2) &&
    export VPC=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[].{id:VpcId}' --output text)

    terraform plan -var-file=terraform-$ENVIRO.tfvars -var=VPC=$VPC -var=ENVIRO=$ENVIRO

    terraform apply -var-file=terraform-$ENVIRO.tfvars -var=VPC=$VPC -var=ENVIRO=$ENVIRO


Then, enter inside `Ingress` path and Install the Nginx Ingress + Cert Manager of K8s 

    kubectl apply -f ingress-issuer-$ENVIRO.yaml

    ./create-ingress.sh


Then, from gitlab-chart path Install the gitlab chart

    export ENVIRO="yourenviro" 

    ./create-base-gitlab.sh

    ./install-gitlab.sh

    ./post-install.sh


To destroy the Gitlab Rds and Redis environment run :

    export ENVIRO="yourenvironment"

    terraform workspace select $ENVIRO

    export VPC_NAME=$(cat ../../terraform/terraform-prod.tfvars | grep VPC_NAME | cut -f2 -d"=" | cut -d'"' -f2) &&
    export VPC=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[].{id:VpcId}' --output text)

    terraform destroy -var-file=terraform-$ENVIRO.tfvars -var VPC=$VPC -var ENVIRO=$ENVIRO






    


    






