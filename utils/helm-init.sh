#!/usr/bin/env bash

if ! command -v helm 2>&1 > /dev/null; then
  echo "Helm not found. Installing helm..."
  OS=linux
  if [[ "$(uname -s)" =~ Darwin* ]]; then
    OS=darwin
  fi
  #HELM=helm-v2.9.0-$OS-amd64
  HELM=helm-v2.14.0-$OS-amd64
  cd /tmp
  wget -q https://kubernetes-helm.storage.googleapis.com/$HELM.tar.gz
  tar xf $HELM.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin
  rm -fr linux-amx64 $HELM.tar.gz
  cd -
  if ! command -v helm 2>&1 > /dev/null; then
    echo "Failed installation of Helm. Please check the script and debug. "
    exit 1
  fi
  echo "Helm successfully installed on your machine."
fi
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller
helm init --service-account tiller --wait
