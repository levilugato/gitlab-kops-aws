#!/usr/bin/env bash

set -e -o pipefail

export CLOUD_PROVIDER="aws"
export IMAGE=k8s.gcr.io/cluster-autoscaler:v1.2.2
export TF_OUTPUT=$(cd ../terraform && terraform output -json)
export REGION="$(echo ${TF_OUTPUT} | jq -r .region.value)"
export CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"

export MIN_NODES=0
export MAX_NODES=10
export GROUP_NAME="nodes-spot.$CLUSTER_NAME"
export SSL_CERT_PATH="/etc/ssl/certs/ca-certificates.crt" 

addon=cluster-autoscaler.yml
wget -O ${addon} https://raw.githubusercontent.com/kubernetes/kops/master/addons/cluster-autoscaler/v1.8.0.yaml

sed -i -e "s@{{CLOUD_PROVIDER}}@${CLOUD_PROVIDER}@g" "${addon}"
sed -i -e "s@{{IMAGE}}@${IMAGE}@g" "${addon}"
sed -i -e "s@{{MIN_NODES}}@${MIN_NODES}@g" "${addon}"
sed -i -e "s@{{MAX_NODES}}@${MAX_NODES}@g" "${addon}"
sed -i -e "s@{{GROUP_NAME}}@${GROUP_NAME}@g" "${addon}"
sed -i -e "s@{{AWS_REGION}}@${REGION}@g" "${addon}"
sed -i -e "s@{{SSL_CERT_PATH}}@${SSL_CERT_PATH}@g" "${addon}"

############### Create Cluster Auto-Scaler ##########
echo "Creating cluster Auto-scaler....."
kubectl apply -f ${addon}

################ create metrics-server for monitoring ########################
echo " "
echo "creating metrics-server for monitoring........"
sleep 15
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update 
helm install metrics-server stable/metrics-server --set args={"--kubelet-insecure-tls=true,--kubelet-preferred-address-types=InternalIP\,Hostname\,ExternalIP"}

################ create Kubernetes Dashboard ########################
echo " "
echo "creating Kubernetes Dashboard......"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa

