#!/bin/bash
#Author: Jialiang Chen
#Date: 07-05-2023
#Desc: Program that tests SNMP on router (DMZ)

echo "* Testing router's SNMP..."
echo "----------------"
echo "-----system-----"
echo "----------------"
snmpwalk -v 2c -c public 203.0.113.33 system
echo "------------------"
echo "-----hrSystem-----"
echo "------------------"
snmpwalk -v 2c -c public 203.0.113.33 hrSystem
echo "-----------------"
echo "-----prTable-----"
echo "-----------------"
snmptable -v 2c -c x5161536z ns UCD-SNMP-MIB::prTable
echo "------------------"
echo "-----dskTable-----"
echo "------------------"
snmptable -v 2c -c x5161536z ns ucdavis.dskTable
echo "-----------------"
echo "-----laTable-----"
echo "-----------------"
snmptable -v 2c -c x5161536z ns ucdavis.laTable
echo "-------------------------------"
echo "-----UCD-SNMP-MIB:dskTable-----"
echo "-------------------------------"
snmptranslate -Td -OS UCD-SNMP-MIB::ucdavis.dskTable
echo "-------------------------------"
echo "-----V3: system.sysDescr.0-----"
echo "-------------------------------"
snmpget -v3 -u gsxViewer -l authNoPriv -a SHA -A "autz6351615x" ns system.sysDescr.0
snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A "autz6351615x" -x DES -X "secz6351615x" ns system.sysDescr.0
