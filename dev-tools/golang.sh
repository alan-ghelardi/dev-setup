#!/usr/bin/env bash
set -euxo pipefail

GOLANG_VERSION=1.18

curl --silent --location https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz --output golang.tar.gz && \
    sudo tar -C /usr/local -xvzf golang.tar.gz && \
    go version && \
    rm golang.tar.gz

# Install gopls
go install golang.org/x/tools/gopls@latest

# Allow private Git modules
go env -w GOPRIVATE=github.com/nubank/*
