#!/usr/bin/env bash
set -euxo pipefail


KO_VERSION=0.9.3
OS=Linux
ARCH=x86_64

curl -L https://github.com/google/ko/releases/download/v${KO_VERSION}/ko_${KO_VERSION}_${OS}_${ARCH}.tar.gz | tar xzf - ko && \
    chmod +x ./ko && \
    sudo mv ./ko /usr/local/bin/
