#! /bin/bash
# Author: Jialiang Chen
# Date: 08-03-2023
# Initialization script for server container
#
# Server's IP = 203.0.113.62

# A) Set /etc/network/interfaces
#config='auto lo\n'\
#'iface lo inet loopback\n'\
#'\n'\
#'auto eth0\n'\
#'iface eth0 inet static\n'\
#'\taddress	203.0.113.62\n'\
#'\tnetwork	203.0.113.32\n'\
#'\tnetmask	255.255.255.224\n'\
#'\tbroadcast	203.0.113.63\n'\
#'\tgateway	203.0.113.33\n'

#eth0config=$'address: 203.0.113.62\nnetwork: 203.0.113.32\nnetmask: 255.255.255.224\nbroadcast: 203.0.113.63\ngateway: 203.0.113.33'
#if [ "$(ifquery eth0)" = "$eth0config" ]
#then
#	echo "Config file interfaces already set, no modifications needed."
#else
#	echo -e $config > /etc/network/interfaces
#	echo "config lines added to interfaces."
#fi
echo "setting up IP..."

ip link set dev eth0 down
ip link set dev eth0 address 00:16:3e:8d:d4:a8
ip link set dev eth0 up

ifdown eth0
ifup eth0
ifquery --state eth0

# C)
cat /etc/hosts | grep -e $'203.0.113.33\trouter' > /dev/null
if [ $? -ne 0 ]; then
	echo -e "203.0.113.33\trouter" >> /etc/hosts
else
	echo "hosts is already set up for server."
fi

# E)
echo "searching for ssh services..."
grep ssh /etc/services
echo "searching for processes that are listening to tcp/numeric..."
ss -4ltn
echo "checking if SSH is installed..."
dpkg -s openssh-server
if [ $? -ne 0 ]; then
	echo "ATTENTION: ssh not installed.\nProceding to install SSH..."
	apt install -y openssh-server
	systemctl status ssh
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


# Date: 09-04-2023
# LabX3


