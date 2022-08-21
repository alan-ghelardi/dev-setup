#!/usr/bin/env bash
set -euxo pipefail

export TKN_VERSION=0.25.0

curl -LO https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz
sudo tar xvzf tkn_${TKN_VERSION}_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
rm tkn_${TKN_VERSION}_Linux_x86_64.tar.gz
