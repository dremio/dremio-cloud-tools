################################################################
# Image with useful cloud tools installed:
#   - aws cli
#   - eksctl
#   - azure cli
#   - gcloud
#   - kubectl
#   - helm
#   - git
#
# An image built with this is published in Dockerhub as
# dremio/cloud-tools
#
################################################################
FROM centos

ADD helm-init.sh /usr/local/bin

RUN \
  yum install -y epel-release && \
  yum install -y which openssl git python-pip && \
  pip install --upgrade pip && \
  pip install awscli && \
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
  mv /tmp/eksctl /usr/local/bin && \
  curl -s -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator && \
  chmod +x ./aws-iam-authenticator && \
  mv aws-iam-authenticator /usr/local/bin && \
  curl -s -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv kubectl /usr/local/bin && \
  curl -s -L https://git.io/get_helm.sh | bash && \
  rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
  sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
  yum install -y azure-cli && \
  curl https://sdk.cloud.google.com | bash

WORKDIR /root
