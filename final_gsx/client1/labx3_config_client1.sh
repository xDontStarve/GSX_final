#!/bin/bash
grep 'send dhcp-lease-time 604800;' /etc/dhcp/dhclient.conf > /dev/null
if [ $? -ne 0 ]; then
	echo "*Lease time not set up for client1"
	echo -e "send dhcp-lease-time  604800;" >> /etc/dhcp/dhclient.conf
else
	echo "OK: Lease time already set up for client1."
fi

grep $'192.168.0.1\trouter\n203.0.113.62\tserver' /etc/hosts > /dev/null
if [ $? -ne 0 ]; then
	echo "*Host router not set up in /etc/hosts"
	echo -e '192.168.0.1\trouter\n203.0.113.62\tserver' >> /etc/hosts
else
	echo "OK: hosts set up already."
fi

ifdown eth0
ifup eth0

echo "searching for ssh services..."
grep ssh /etc/services >/dev/null
echo "searching for processes that are listening to tcp/numeric..."
ss -4ltn
echo "checking if SSH is installed..."
dpkg -s openssh-server >/dev/null
if [ $? -ne 0 ]; then
	echo "ATTENTION: ssh not installed.\nProceding to install SSH..."
	apt install -y openssh-server > /dev/null
	systemctl status ssh >/dev/null
	ss -4lnt | grep ":22"
else
	echo "SSH is installed."
fi

grep $'PermitRootLogin\tyes' /etc/ssh/sshd_config > /dev/null
if [ $? -ne 0 ]; then
	echo "Setting PermitRootLogin to yes"
	echo -e 'PermitRootLogin\tyes' >> /etc/ssh/sshd_config
else
	echo "PermitRootLogin is already set to yes"
fi

echo "Restarting SSH..."
systemctl restart ssh
