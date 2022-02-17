#!/usr/bin/env bash
set -euxo pipefail

kind_version=0.11.1

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${kind_version}/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
