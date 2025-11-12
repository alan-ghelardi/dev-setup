#!/usr/bin/env bash
set -euxo pipefail

bb_version=1.12.209

curl -L https://github.com/babashka/babashka/releases/download/v$bb_version/babashka-$bb_version-linux-amd64-static.tar.gz -o bb.tar.gz
tar -vxf bb.tar.gz
sudo mv bb /usr/local/bin/
rm bb.tar.gz
