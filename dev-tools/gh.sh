#!/usr/bin/env bash
set -euxo pipefail

gh_version=2.49.2

curl -L https://github.com/cli/cli/releases/download/v${gh_version}/gh_${gh_version}_linux_amd64.tar.gz -o gh.tar.gz
tar xvzf gh.tar.gz
sudo mv gh_${gh_version}_linux_amd64/bin/gh /usr/local/bin/gh
rm -rf gh.tar.gz gh_${gh_version}_linux_amd64
