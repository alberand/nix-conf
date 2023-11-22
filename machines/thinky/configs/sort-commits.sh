#!/usr/bin/env sh

if [ "$#" -ne 1 ]; then
    echo "Specify main branch"
    exit 1
fi

MAIN="$1"
COMMITS=$(git rev-list --count HEAD ^$MAIN)
REBASE=$(mktemp)

for downstream_commit in $(git log --oneline --format="%H" -n $COMMITS); do
	upstream_commit=$(git show --format=%B $downstream_commit | \
		awk '/^commit/ {print $2}')
	date=$(git show --no-patch --pretty='%at' $upstream_commit)
	echo "$downstream_commit $upstream_commit $date"
done | sort -k3 -n | awk '{ print "pick "$1 }' | tee $REBASE

echo ""
echo "Use it for rebase:"
echo git rebase -i $MAIN
