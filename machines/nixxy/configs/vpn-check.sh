template='{"text": "$text", "tooltip": "", "class": "$class", "percentage": 0 }'

mullvad_exit_ip=$(curl -s https://am.i.mullvad.net/json | jq ."mullvad_exit_ip")

if [ "$mullvad_exit_ip" == "true" ]; then 
	template=$(echo $template | sed 's/$text/VPN/' | \
		sed 's/$class/connected/'); 
else 
	template=$(echo $template | sed 's/$text/No VPN/' | \
		sed 's/$class/disconnected/'); 
fi

echo $template;
