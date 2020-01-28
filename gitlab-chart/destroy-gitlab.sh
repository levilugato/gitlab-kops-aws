#!/usr/bin/env bash

set -e -o pipefail  

helm delete $ENVIRO-gitlab -n $ENVIRO-gitlab
Kubectl delete ns $ENVIRO-gitlab


