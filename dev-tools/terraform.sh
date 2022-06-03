#!/usr/bin/env bash
set -euxo pipefail

terraform_version=1.2.2

curl --output terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
unzip -o terraform.zip
sudo mv terraform /usr/local/bin/
rm terraform.zip
