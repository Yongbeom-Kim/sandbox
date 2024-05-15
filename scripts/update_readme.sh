#!/bin/bash

dirs=(*/)
dirs+=(".")

cd $(git rev-parse --show-toplevel)
bash scripts/link_script.sh

base_dir="$(git rev-parse --show-toplevel)"
for dir in "${dirs[@]}"; do
    if [[ $dir == "scripts/" ]]; then
        continue
    fi
    echo "Updating README in $dir"
    cd $base_dir/$dir
    bash update_desc_script.sh
done