#!/bin/bash
readmes=("$(find . -wholename ./*/README.md)")
echo ${readmes[@]}

table="\n"
table+="\n"
table+="## Sub-Repositories\n"
table+="\n"
table+="| Sub-repository | Description |\n"
table+="| --- | --- |\n"


for readme in ${readmes[@]}; do
    repo=$(dirname $readme)
    # Get the first line of the README that is not a header
    description=$(cat $readme | egrep '^[^#]+' -m 1)
    table+="| [$repo]($repo) | $description |\n"
done


# Remove the old table
perl -0777 -i -pe 's/\#+\s*Sub-Repositories[\s\S]*(?=\#|\n)//g' README.md

# Remove trailing whitespace
perl -0777 -i -pe 's/\s+$//g' README.md

echo -e $table >> README.md

# Remove trailing whitespace
perl -0777 -i -pe 's/\s+$//g' README.md