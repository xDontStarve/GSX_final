#!/bin/bash
# Config script to set up DNMP agents in Milax containers
# Author: Jialiang Chen
# Date: 03-05-2023
# Ver: 1.1

#DNI, IND, IP
DNI="x5161536z"
IND="z6351615x"
IP="203.0.113.33"

# Installing packages
if [[ ! $(dpkg -s snmp) ]]; then apt install -y snmp; else echo "[OK] snmp installed."; fi

if [[ ! $(dpkg -s snmpd) ]]; then apt install -y snmpd; else echo "[OK] snmpd installed."; fi

if [[ ! $(dpkg -s smistrip) ]]; then apt install -y smistrip; else echo "[OK] smistrip installed."; fi

if [[ ! $(dpkg -s patch) ]]; then apt install -y patch; else echo "[OK] patch installed."; fi

if [[ ! $(dpkg -s snmp-mibs-downloader) ]]; then apt install -y snmp-mibs-downloader; else echo "[OK] snmp-mibs-downloader installed."; fi

echo "-Finished checking packages..."

# snmp.conf:
grep "mibdirs + /usr/share/mibs" /etc/snmp/snmp.conf > /dev/null
if [[ $? -ne 0 ]]; then
	echo "* Setting up snmp.conf..."
	echo -e "mibdirs + /usr/share/mibs
mibs +All" >> /etc/snmp/snmp.conf
else	echo "[OK] snmp directory already added"
fi

# snmpd.conf:
grep "#snmpd.conf set up" /etc/snmp/snmpd.conf > /dev/null
if [[ $? -ne 0 ]]; then
	echo "* Setting up snmpd.conf..."
	echo -e "###########################################################################
#
# snmpd.conf
# An example configuration file for configuring the Net-SNMP agent ('snmpd')
# See snmpd.conf(5) man page for details
#
###########################################################################
# SECTION: System Information Setup
#

# Definició dels usuaris SNMPv3
createUser gsxViewer SHA autz6351615x
createUser gsxAdmin SHA autz6351615x DES secz6351615x

# syslocation: The [typically physical] location of the system.
#   Note that setting this value here means that when trying to
#   perform an snmp SET operation to the sysLocation.0 variable will make
#   the agent return the notWritable error code.  IE, including
#   this token in the snmpd.conf file will disable write access to
#   the variable.
#   arguments:  location_string
sysLocation    Reus
sysContact     JialiangC <jialiang.chen@estudiants.urv.cat>

# sysservices: The proper value for the sysServices object.
#   arguments:  sysservices_number
sysServices    72



###########################################################################
# SECTION: Agent Operating Mode
#
#   This section defines how the agent will operate when it
#   is running.

# master: Should the agent operate as a master agent or not.
#   Currently, the only supported master agent type for this token
#   is agentx.
#   
#   arguments: (on|yes|agentx|all|off|no)

master  agentx

# agentaddress: The IP address and port number that the agent will listen on.
#   By default the agent listens to any and all traffic from any
#   interface on the default SNMP port (161).  This allows you to
#   specify which address, interface, transport type and port(s) that you
#   want the agent to listen on.  Multiple definitions of this token
#   are concatenated together (using ':'s).
#   arguments: [transport:]port[@interface/address],...

# agentaddress  127.0.0.1,[::1]
agentaddress udp:161



###########################################################################
# SECTION: Access Control Setup
#
#   This section defines who is allowed to talk to your running
#   snmp agent.

# Views 
#   arguments viewname included [oid]

#  system + hrSystem groups only
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1

# Fix system view for vistagsx
# view vistagsx included .1.3.6.1.2
# interfaces
view vistagsx included .1.3.6.1.2.1.2
view vistagsx included .1.3.6.1.2.1.37.1.2.1.15
# ip
view vistagsx included .1.3.6.1.2.1.4
view vistagsx included .1.3.6.1.2.1.48
# icmp
view vistagsx included .1.3.6.1.2.1.5
# ucdavis
view vistagsx included .1.3.6.1.4.1.2021
# SNMPv2
view vistagsx included .1.3.6.1.6
view vistagsx included .1.3.6.1.2.1.11


# rocommunity: a SNMPv1/SNMPv2c read-only access community name
#   arguments:  community [default|hostname|network/bits] [oid | -V view]

rocommunity x5161536z 203.0.113.32/27 -V vistagsx

# Read-only access to everyone to the systemonly view
rocommunity  public default -V systemonly
rocommunity6 public default -V systemonly

# SNMPv3 doesn't use communities, but users with (optionally) an
# authentication and encryption string. This user needs to be created
# with what they can view with rouser/rwuser lines in this file.
#
# createUser username (MD5|SHA|SHA-512|SHA-384|SHA-256|SHA-224) authpassphrase [DES|AES] [privpassphrase]
# e.g.
# createuser authPrivUser SHA-512 myauthphrase AES myprivphrase
#
# This should be put into /var/lib/snmp/snmpd.conf 
#
# rouser: a SNMPv3 read-only access username
#    arguments: username [noauth|auth|priv [OID | -V VIEW [CONTEXT]]]
rouser authPrivUser authpriv -V systemonly
rouser gsxViewer AuthNoPriv
rwuser gsxAdmin AuthPriv
#snmpd.conf set up
" > /etc/snmp/snmpd.conf
else
	echo "[OK] snmpd.conf already set up"
fi

#grep -e "createUser gsxViewer SHA autz6351615x
#createUser gsxAdmin SHA autz6351615x DES secz6351615x" /var/lib/snmp/snmpd.conf > /dev/null
#if [[ $? -ne 0 ]]; then
#	echo "/var/lib/snmp/snmpd.conf not set up, proceeding to do so"
#	echo -e "createUser gsxViewer SHA autz6351615x
#createUser gsxAdmin SHA autz6351615x DES secz6351615x" >> /var/lib/snmp/snmpd.conf
#else
#	echo "[OK] /var/lib/snmp/snmpd.conf set up."
#fi

echo "* Restarting snmpd..."
systemctl restart snmpd
