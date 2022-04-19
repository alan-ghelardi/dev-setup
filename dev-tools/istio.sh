#!/usr/bin/env bash
set -euxo pipefail

istio_version=1.13.3

curl -Lo istio.tar.gz https://github.com/istio/istio/releases/download/${istio_version}/istio-${istio_version}-linux-amd64.tar.gz
tar -xvf istio.tar.gz istio-${istio_version}/bin/istioctl
sudo mv istio-${istio_version}/bin/istioctl /usr/local/bin/
rm -rf istio-${istio_version} istio.tar.gz
