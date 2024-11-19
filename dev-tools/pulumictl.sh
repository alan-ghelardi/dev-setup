#!/usr/bin/env bash
set -euxo pipefail

pulumictl_version=0.0.46

curl -L https://github.com/pulumi/pulumictl/releases/download/v${pulumictl_version}/pulumictl-v${pulumictl_version}-linux-amd64.tar.gz -o pulumictl.tar.gz
tar xvzf pulumictl.tar.gz pulumictl
sudo mv pulumictl /usr/local/bin/
rm -rf pulumictl.tar.gz
