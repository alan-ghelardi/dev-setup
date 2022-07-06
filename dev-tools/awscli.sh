#!/usr/bin/env bash
set -euxo pipefail

curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws
