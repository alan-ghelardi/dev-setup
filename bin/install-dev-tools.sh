#!/usr/bin/env bash

set -euo pipefail

cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

mkdir -p /tmp/dev-tools
cd /tmp/dev-tools

for file in $(ls ${cur_dir}/../dev-tools/*.sh); do
    tool=$(basename $file | cut -d'.' -f1)
    echo "installing $tool"
    source $(realpath $file)
done
