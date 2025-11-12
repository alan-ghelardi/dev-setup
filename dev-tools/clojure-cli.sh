#!/usr/bin/env bash
set -euxo pipefail

CLOJURE_CLI_VERSION="1.12.3.1577"

curl -o linux-install.sh https://download.clojure.org/install/linux-install-${CLOJURE_CLI_VERSION}.sh && \
    chmod +x linux-install.sh && \
    sudo ./linux-install.sh && \
    rm linux-install.sh
