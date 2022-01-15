#!/usr/bin/env bash

set -euo pipefail

cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

for service in $(ls $cur_dir/../vmware/*.service); do
    sudo cp $service /etc/systemd/system/
    sudo systemctl enable $(basename $service)
done
