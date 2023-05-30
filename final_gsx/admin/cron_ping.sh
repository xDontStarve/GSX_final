#!/bin/bash
#Author: Jialiang Chen
#Date: 25-05-023
#Desc: cron service to check ping numbers, if ping number is higher than 10 within two snmp checks

n_pings=snmpget -On -v3 -u gsxViewer -l authNoPriv -a SHA -A "autz6351615x" ns icmpMsgStatsInPkts.ipv4.8 | awk -F':'' ' '{print $2}'
if  [[ n_pings -ge 10 ]]; then
	logger -p user.warning -t GSX "AVÍS: nombre de pings al router $npings és masa alt"
fi

