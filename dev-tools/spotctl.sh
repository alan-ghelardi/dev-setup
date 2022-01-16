#!/usr/bin/env bash
set -euxo pipefail

spotctl_version=0.25.0

curl -L https://github.com/spotinst/spotctl/releases/download/v$spotctl_version/spotctl-linux-amd64-$spotctl_version.tar.gz -o spotctl.tar.gz
tar -vxf spotctl.tar.gz
sudo mv spotctl /usr/local/bin/
rm  spotctl.tar.gz
