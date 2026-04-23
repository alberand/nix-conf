#!/usr/bin/env bash

branch=$1
original=$2

cover=$(jj log -r "(first_ancestors($branch) & empty())" --no-graph -n 1 -T 'change_id ++ "\n"')
total=$(($(jj log -r $cover:: -T 'change_id ++ "\n"' --no-graph | wc -l) - 3))

for i in $(seq $total -1 0); do
	output=$(jj interdiff \
			--to "parents($branch, $i)" \
			--from "parents($original, $i)" \
			2>&1)
	if [ -n "$output" ]; then
		jj log \
			-r "parents($branch, $i)" \
			-T 'change_id.shortest() ++ " (" ++ commit_id.short() ++ ") " ++ description.first_line() ++ "\n"'\
			--no-graph
		echo "$output"
	fi
done
