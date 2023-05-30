#! /bin/bash
# Author: Jialiang Chen
# Date: 08-03-2023
# Initialization script for router container
#
# Router's IP = 203.0.113.33
# Server's IP = 203.0.113.62

# A)
ip -f inet addr show eth1 | grep "203.0.113.33" > /dev/null
if [ $? -ne 0 ]; then
	ip address add 203.0.113.33/27 broadcast \ 203.0.113.63 dev eth1
else
	echo "ip address is already set up for router."
fi
ip link set eth1 up

# B)
sysctl -w net.ipv4.ip_forward=1

# C)
cat /etc/hosts | grep -e $'203.0.113.62\tserver' > /dev/null
if [ $? -ne 0 ]; then
	echo -e "203.0.113.62\tserver" >> /etc/hosts
else
	echo "hosts is already set up for router."
fi

# D)


iptables -t nat -C POSTROUTING -s 203.0.113.32/27 -o eth0 -j MASQUERADE > /dev/null
if [ $? -ne 0 ]; then
	iptables -t nat -A POSTROUTING -s 203.0.113.32/27 -o eth0 -j MASQUERADE
else
	echo "iptables is already set up."
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

