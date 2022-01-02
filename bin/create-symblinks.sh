#!/usr/bin/env bash

set -euo pipefail

cur_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

dotfiles=$(realpath $cur_dir/../dotfiles)

for file in $(ls -A $dotfiles/conf); do
    source=$dotfiles/conf/$file
    target=$HOME/$file
    ln -s $source $target
done
