#!/usr/bin/env bash
set -euxo pipefail

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"


KUBECTL_VERSION=1.36.0
chmod a+x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
