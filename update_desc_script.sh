#!/bin/bash

table="\n"
table+="\n"
table+="## Sub-Repositories\n"
table+="\n"
table+="| Sub-repository | Description |\n"
table+="| --- | --- |\n"

readmes=(./*/README.md)
if [[ $(ls -d */ | wc -l) -eq 0 ]]; then
    readmes=()
fi

echo "Found ${#readmes[@]} sub-repositories in $(pwd): ${readmes[@]}"

for readme in ${readmes[@]}; do
    repo=$(dirname $readme)
    # Get the first line of the README that is not a header
    description=$(cat $readme | egrep '^[^#]+' -m 1)
    table+="| [$repo]($repo) | $description |\n"
done

if [[ "${#readmes[@]}" -eq 0 ]]; then
    table+="| No sub-repositories | - |"
fi


# Remove the old table
perl -0777 -i -pe 's/\#+\s*Sub-Repositories[\s\S]*(?=\#?)//g' README.md

# Remove trailing whitespace
perl -0777 -i -pe 's/\s+$//g' README.md

echo -e $table >> README.md

# Remove trailing whitespace
perl -0777 -i -pe 's/\s+$//g' README.md