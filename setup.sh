cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
sed -n -i 'p;1a bash update_desc.sh' .git/hooks/pre-commit