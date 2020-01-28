#!/usr/bin/env bash

set -e -o pipefail

export NS=$ENVIRO-gitlab

# CHANGE RAILS SECRET
kubectl delete secret $NS-rails-secret -n $NS
kubectl create secret generic $NS-rails-secret --from-file=secrets.yml=restore-bkp-secrets.yaml -n $NS

# DELETE OLD GITLAB RUNNER SECRET
kubectl delete secret $NS-gitlab-runner-secret -n $NS

# CREATE NEW SECRET WITH NEW TOKEN
kubectl create secret generic $NS-gitlab-runner-secret --from-literal=runner-registration-token="youroldgitlabrunnertoken" --from-literal=runner-token="" -n $NS

# Recreate pods 
kubectl delete pods -lapp=sidekiq,release=$NS -n $NS

kubectl delete pods -lapp=unicorn,release=$NS -n $NS

kubectl delete pods -lapp=task-runner,release=$NS -n $NS