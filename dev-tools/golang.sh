#!/usr/bin/env bash
set -euxo pipefail

GOLANG_VERSION=1.21.8

curl --silent --location https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz --output golang.tar.gz && \
    sudo tar -C /usr/local -xvzf golang.tar.gz && \
    go version && \
    rm golang.tar.gz

# Install gopls
go install golang.org/x/tools/gopls@latest

# Install kubeconform: https://github.com/yannh/kubeconform.
go install github.com/yannh/kubeconform/cmd/kubeconform@latest

# Install Golang debugger.
go install github.com/go-delve/delve/cmd/dlv@latest

# Install golangci-lint.
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.57.1

# Cosign:
go install github.com/sigstore/cosign/v2/cmd/cosign@latest

# Allow private Git modules
go env -w GOPRIVATE=github.com/nubank/*
