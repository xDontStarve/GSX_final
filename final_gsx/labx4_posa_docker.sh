#!/bin/bash
# Date: 11-04-2023
# Script to create the docker container

# Check if docker is in milax group
if [[ -z $(groups milax | grep "docker") ]]; then
	usermod -aG docker milax	
else
	echo "OK: milax is in docker group"
fi

# Stop docker first
systemctl stop docker
# backup of iptables
iptables-save > inicials
iptables -t nat -F
iptables -t filter -F
iptables -t mangle -F
# Delete docker bridge
ip link rm docker0
# Disable IP tables managing by docker
touch /etc/docker/daemon.json
echo '{ "iptables": false }' > /etc/docker/daemon.json
# Save status and restart docker
systemctl start docker
# Creating bridge to connect to DMZ
docker network create --driver=bridge --subnet=203.0.113.32/27 DMZ
bridge_name=$(docker network ls | grep DMZ | cut -f1 -d" ")
# Bridge name starts with br-
bridge_name=$(echo -e $"br-$bridge_name")
# Connect the two bridges
if [[ -z $(ip a | grep veth10) ]]; then
	ip link add veth10 type veth peer name veth20
	ip link set veth10 master $bridge_name
	ip link set dev veth10 up
	ip link set veth20 master lxcbr1
	ip link set dev veth20 up
fi
