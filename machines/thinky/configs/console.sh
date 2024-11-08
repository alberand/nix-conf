#!/usr/bin/env bash

function _console()
{
	klist -s >& /dev/null
	[ $? -ne 0 ] && echo "No valid kerberos ticket found.  Please Authenticate" && kinit
	local OPT=$(shopt -p -o nounset)
	set -o nounset
	local HOST
	if [ $# -eq 0 ]; then
		echo -n "Machine name: "
		read HOST
		[ -z "$HOST" ] && return
	else
		HOST=$1
	fi

	case ${HOST} in
	# from https://docs.engineering.redhat.com/x/dWMqAw
	*bos2*) CONSERVER="conserver-01.cons-001.eng.bos2.dc.redhat.com";;
	*bos*) CONSERVER="conserver-01.cons-001.eng.bos2.dc.redhat.com";;
	*rdu2*) CONSERVER="conserver-02.eng.rdu2.redhat.com";;
	*rdu*) CONSERVER="console.eng.rdu.redhat.com";;
	*brq*) CONSERVER="conserver-01.host.prod.eng.brq2.redhat.com";;
	*bne*) CONSERVER="console.englab.bne.redhat.com";;
	*pek*) CONSERVER="conserver-01.eng.pek2.redhat.com";;
	*pnq*) CONSERVER="console.lab.eng.pnq.redhat.com";;
	*nay*) CONSERVER="console.lab.eng.nay.redhat.com";;
	*tlv*) CONSERVER="conserver-01.eng.tlv.redhat.com";;
	*)     CONSERVER="conserver-01.cons-001.eng.bos2.dc.redhat.com";;
	esac

	console -M ${CONSERVER} ${HOST}
	eval ${OPT}
}

_console $@
read -p "Press any key to exit > " -n1 exitjunk
echo
