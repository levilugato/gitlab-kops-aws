#!/usr/bin/env bash

set -e -o pipefail 

#Create helm chart for Nginx Ingress
helm upgrade --install nginx-ingress stable/nginx-ingress -f ./values-ingress.yaml --set tcp.22="$ENVIRO-gitlab/$ENVIRO-gitlab-gitlab-shell:22" -n default

sleep 5

#Create Crds for cert-manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml --validate=false
kubectl label namespace default certmanager.k8s.io/disable-validation=true

sleep 5

#Install Cert-manager
kubectl apply -f ingress-issuer-$ENVIRO.yaml
helm repo add jetstack https://charts.jetstack.io/
helm repo update
helm install cert-manager --namespace default --version v0.9.1 jetstack/cert-manager
