#!/usr/bin/env bash
set -euxo pipefail

GOLANG_VERSION=1.19

curl --silent --location https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz --output golang.tar.gz && \
    sudo tar -C /usr/local -xvzf golang.tar.gz && \
    go version && \
    rm golang.tar.gz

# Install gopls
go install golang.org/x/tools/gopls@latest

go install honnef.co/go/tools/cmd/staticcheck@2023.1.3

# Allow private Git modules
go env -w GOPRIVATE=github.com/nubank/*
