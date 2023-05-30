#!/bin/bash
#Author: Jialiang Chen
#Date: 24-05-2023
#Description: Script to execute all other scripts to configure containers.
cp update-hostname /etc/dhcp/dhclient-exit-hooks.d
./labx3_config_admin.sh
./labx6_config_snmp.sh
apt install -y --fix-missing cron
cp cron_ping.sh /usr/sbin/
line="*/10 * * * * /usr/sbin/cron_ping.sh"
(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
systemctl restart cron
./proves_snmp.sh
