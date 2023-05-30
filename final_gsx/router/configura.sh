#!/bin/bash
#Author: Jialiang Chen
#Date: 24-05-2023
#Description: Script to execute all other scripts to configure containers.
#cp update-hostname /etc/dhcp/dhclient-exit-hooks.d
./labx1_static_config_router.sh
./labx3_config_router.sh
./labx5_config_router.sh
./labx6_config_snmp.sh
./proves_snmp.sh
