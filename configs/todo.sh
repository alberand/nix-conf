#!/usr/bin/env sh

host=$(hostname)

if [ $host == "thinky" ]; then
	if ! mountpoint -q /mnt/lonmoun; then
		echo "Mount share point:"
		echo "\tsudo mount /mnt/lonmoun";
		exit 1
	fi
	$EDITOR /mnt/lonmoun/todo
fi

if [ $host == "nixxy" ]; then
	$EDITOR ~/Share/local/todo
fi
