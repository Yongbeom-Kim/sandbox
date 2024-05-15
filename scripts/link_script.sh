#!/bin/bash

cd $(git rev-parse --show-toplevel)

dirs=(*/)

for dir in "${dirs[@]}"; do
    if [[ $dir == "scripts/" ]]; then
        continue
    fi
    echo "Linking update_desc_script.sh to $dir"
    ln -s ../update_desc_script.sh $dir/update_desc_script.sh
done