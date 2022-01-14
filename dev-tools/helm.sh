#!/usr/bin/env bash
set -euxo pipefail

helm_version=3.7.2

curl -L https://get.helm.sh/helm-v$helm_version-linux-amd64.tar.gz -o helm.tar.gz
tar xvzf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm.tar.gz linux-amd64
