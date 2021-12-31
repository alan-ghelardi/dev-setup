#!/usr/bin/env bash
set -euxo pipefail

GH_VERSION=2.4.0

curl -L https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_386.tar.gz &&
    sudo tar xvzf gh_${GH_VERSION}_linux_386.tar.gz -C /usr/local/bin/ gh
