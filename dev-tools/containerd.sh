#!/usr/bin/env bash

set -euxo pipefail

containerd_version=1.7.16
runc_version=1.1.12
network_plugins_version=1.4.1

curl -LO https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-amd64.tar.gz

sudo tar Cxzvf /usr/local containerd-${containerd_version}-linux-amd64.tar.gz
rm containerd-${containerd_version}-linux-amd64.tar.gz

curl -LO https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64

curl -LO https://github.com/containernetworking/plugins/releases/download/v${network_plugins_version}/cni-plugins-linux-amd64-v${network_plugins_version}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${network_plugins_version}.tgz
rm cni-plugins-linux-amd64-v${network_plugins_version}.tgz

sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd
