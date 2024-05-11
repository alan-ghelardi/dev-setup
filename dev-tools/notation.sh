#!/usr/bin/env bash

set -euxo pipefail

NOTATION_VERSION=1.1.0

curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_linux_amd64.tar.gz
sudo tar xvzf notation_$NOTATION_VERSION\_linux_amd64.tar.gz -C /usr/bin/ notation
rm -f notation_$NOTATION_VERSION\_linux_amd64.tar.gz

curl -LO https://d2hvyiie56hcat.cloudfront.net/linux/amd64/plugin/latest/notation-aws-signer-plugin.zip
unzip notation-aws-signer-plugin.zip -x LICENSE -x THIRD_PARTY_LICENSES
rm notation-aws-signer-plugin.zip
mkdir -p ~/.config/notation/plugins/com.amazonaws.signer.notation.plugin
mv notation-com.amazonaws.signer.notation.plugin ~/.config/notation/plugins/com.amazonaws.signer.notation.plugin/
