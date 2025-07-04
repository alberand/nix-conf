#!/usr/bin/env bash

usage() {
	echo "Usage deploy.sh <hostname> <hostip>"
	echo "\tdeploy.sh quesada 10.10.10.69"
}

if [ "$#" -ne 2 ]; then
	usage
	exit 1
fi

if [ -z "$SSHPASS" ]; then
	echo "\$SSHPASS need to be set to target's root password"
fi

host=$1
hostip=$2

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"

cat "./secrets/${host}_ed25519" > "$temp/etc/ssh/ssh_host_ed25519_key"
cat "./secrets/${host}_ed25519.pub" > "$temp/etc/ssh/ssh_host_ed25519_key.pub"

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

sudo SSHPASS=$SSHPASS nix run github:nix-community/nixos-anywhere -- \
	--flake .#$host \
	--target-host root@$hostip \
	--env-password \
	--extra-files "$temp"
