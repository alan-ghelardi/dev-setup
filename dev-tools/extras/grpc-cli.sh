#!/usr/bin/env bash
set -euxo pipefail

git clone https://github.com/grpc/grpc/
cd grpc
git submodule update --init
mkdir -p cmake/build
cd cmake/build
cmake -DgRPC_BUILD_TESTS=ON ../..
make
sudo mv grpc_cli  /usr/bin/
cd ../../../
rm -rf grpc
