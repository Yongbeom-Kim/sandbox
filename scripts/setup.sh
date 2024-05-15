cd $(git rev-parse --show-toplevel)

echo "Creating new pre-commit hook"
cp .git/hooks/pre-commit.sample .git/hooks/pre-commit

echo "Adding scripts/update_readme.sh to pre-commit hook"
sed -n -i 'p;1a cd $(git rev-parse --show-toplevel)' .git/hooks/pre-commit
sed -n -i 'p;1a bash scripts/update_readme.sh' .git/hooks/pre-commit