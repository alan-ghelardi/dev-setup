#!/usr/bin/env bash

set -eux

curl -Lo kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
tar xf kubeval-linux-amd64.tar.gz kubeval
sudo mv kubeval /usr/local/bin
rm kubeval-linux-amd64.tar.gz
