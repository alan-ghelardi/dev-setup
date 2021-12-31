#!/usr/bin/env bash
set -euxo pipefail

KUSTOMIZE_VERSION=4.0.1

curl --silent --location https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz --output kustomize.tar.gz && \
    tar -xzvf kustomize.tar.gz && \
    sudo mv kustomize /usr/local/bin && \
    kustomize version && \
    rm kustomize.tar.gz
