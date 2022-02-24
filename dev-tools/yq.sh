#!/usr/bin/env bash
set -eux

yq_version=4.20.2

curl -Lo yq.tar.gz https://github.com/mikefarah/yq/releases/download/v${yq_version}/yq_linux_amd64.tar.gz
tar -xvf yq.tar.gz ./yq_linux_amd64
sudo mv ./yq_linux_amd64 /usr/local/bin/yq
rm yq.tar.gz
