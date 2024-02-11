#!/usr/bin/env bash

set -euxo pipefail

ETCD_VERSION=v3.5.12

DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

curl -L ${DOWNLOAD_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o etcd.tar.gz
tar xzvf etcd.tar.gz -C . --wildcards --anchored '*/etcdctl' --strip-components 1
rm -f etcd.tar.gz
chmod a+x etcdctl
sudo mv etcdctl /usr/bin/etcdctl
