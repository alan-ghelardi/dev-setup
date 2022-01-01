#!/usr/bin/env bash

set -euo pipefail

cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

mkdir -p ~/.bash.d/

if [[ ! -f ~/.bash.d/.rc.sh ]]; then
    ln -s  $cur_dir/../dotfiles/.rc.sh ~/.bash.d/.rc.sh
fi

for file in $(ls -A ${cur_dir}/../dotfiles/conf); do
    source=$(realpath $file)
    ln -s $source $HOME/$(basename $source)
done
