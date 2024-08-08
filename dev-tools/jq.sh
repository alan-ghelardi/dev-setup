#!/usr/bin/env bash
set -euxo pipefail

jq_version=1.7.1

curl -Lo ./jq https://github.com/jqlang/jq/releases/download/jq-${jq_version}/jq-linux-amd64
chmod a+x ./jq
sudo mv ./jq /usr/bin/jq
