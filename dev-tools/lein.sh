#!/usr/bin/env bash
set -euxo pipefail

export LEIN_VERSION=2.9.1

sudo curl https://raw.githubusercontent.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein \
     --output /usr/bin/lein && \
    sudo chmod +x /usr/bin/lein &&
    lein version
