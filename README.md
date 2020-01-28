## Requirements

* jq
* kops
* aws
* kubectl
* terraform v0.12
* helm v3

## Usage

First of all, you need to install and configure your aws cli client with your AWS credentials:
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

Edit `terraform/terraform-$ENVIRO.tfvars` with your variables 

From the `terraform` directory export the variable (choose your ENVIRO as `staging` or `prod`) of the environment and run:

    export ENVIRO="yourchoice"  
    ./init.sh 
    terraform plan -var-file=terraform-$ENVIRO.tfvars
    terraform apply -var-file=terraform-$ENVIRO.tfvars

The init script will create The Bucket for terraform and Kops states, DynamoDB table for lock resources when necessary and init the backend configuration

Terraform will create the base structure for Kops: VPC, Internet gw, Route tables, Route 53 private zone and expose the variables for later use by Kops scripts.

Then from the `kops` dir edit the script `create-cluster.sh` with your variables and run:

    export ENVIRO="yourenvironment"
    ./create_cluster.sh
 
 After 10 ˜ 15 minutes check if `kops` is ready 

    export TF_OUTPUT=$(cd ../terraform && terraform output -json) && export KOPS_STATE_STORE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_state_store.value)" && export CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)" && kops validate cluster --name $CLUSTER_NAME


Then install the add-ons for the cluster (auto-scaler, metrics-server)

    ./cluster-addons.sh

