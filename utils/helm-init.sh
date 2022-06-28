#!/usr/bin/env bash

if ! command -v helm 2>&1 > /dev/null; then
  echo "Helm not found. Installing helm..."
  curl -L https://git.io/get_helm.sh | bash
  if ! command -v helm 2>&1 > /dev/null; then
    echo "Failed installation of Helm. Please check the script and debug. "
    exit 1
  fi
  echo "Helm successfully installed on your machine."
fi
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller
helm init --service-account tiller --wait
