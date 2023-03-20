#!/usr/bin/env bash
set -euo pipefail

protoc_version=22.2

curl --location --fail --output protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-linux-x86_64.zip
mkdir -p protoc.d
unzip protoc.zip -d protoc.d
mv protoc.d/bin/protoc $GOPATH/bin/protoc
mv protoc.d/include/ $GOPATH/
rm -rf protoc.d protoc.zip

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
