template='{"text": "$text", "tooltip": "", "class": "$class", "percentage": 0 }'

if curl -s https://beaker.engineering.redhat.com > /dev/null; then
	template=$(echo $template | sed 's/$text/VPN/' | \
		sed 's/$class/connected/');
else
	template=$(echo $template | sed 's/$text/No VPN/' | \
		sed 's/$class/disconnected/');
fi

echo $template;
