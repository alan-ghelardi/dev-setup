#!/usr/bin/env bash
set -euxo pipefail

kubeseal_version=0.17.3

curl -Lo ./kubeseal.tar.gz https://github.com/bitnami-labs/sealed-secrets/releases/download/v$kubeseal_version/kubeseal-$kubeseal_version-linux-amd64.tar.gz
tar -xvf kubeseal.tar.gz kubeseal
sudo mv kubeseal /usr/local/bin/
rm kubeseal.tar.gz
