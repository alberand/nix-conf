# Yes "lock" is opposite to unlocked but I like the icon
# I immediately understand what it means
unlocked="";
locked="";

if ssh-add -l > /dev/null 2>&1; then
	ssh_status="$unlocked ssh";
else
	ssh_status="$locked ssh";
fi

if klist > /dev/null 2>&1; then
	krb_status="$unlocked krb";
else
	krb_status="$locked krb";
fi

echo "{\"text\": \"$ssh_status $krb_status\", \"tooltip\": \"\", \"class\": \"locked\", \"percentage\": 0 }";
