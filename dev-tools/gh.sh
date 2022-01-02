#!/usr/bin/env bash
set -euxo pipefail

GH_VERSION=2.4.0

curl -L https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_386.tar.gz -o gh.tar.gz
tar xvzf gh.tar.gz
sudo mv gh_${GH_VERSION}_linux_386/bin/gh /usr/local/bin/gh
rm -rf gh.tar.gz gh_${GH_VERSION}_linux_386
