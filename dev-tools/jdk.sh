#!/usr/bin/env bash
set -euxo pipefail

jdk_download_url="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.11%2B10/OpenJDK21U-jdk_x64_linux_hotspot_21.0.11_10.tar.gz"

curl -sSL -o open-jdk.tar.gz "${jdk_download_url}" | \

    sudo mkdir -p /opt/java

sudo tar -xzf open-jdk.tar.gz -C /opt/java

rm open-jdk.tar.gz
