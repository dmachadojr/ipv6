#!/bin/bash
#-----------------------------------------------
# Script comparativo de ping com IPv4 e IPv6
# Autor: Dorival M Machado Junior
# version: 2.0
#------------------------------------------------

myLocal=$(pwd)

IPv4_server="192.168.1.1"
filePingIPv4="$myLocal/ping4.txt"
filePingIPv4Aux="$myLocal/v4.txt"

IPv6_server="fc00::1:101"
filePingIPv6="$myLocal/ping6.txt"
filePingIPv6Aux="$myLocal/v6.txt"

packetsForSend="30"

comparisonGraph="$myLocal/v4_v6.png"

#Your machine interface
iface="wlan0"


#---|begin|------

# gnuplot test
gnuplot --version > /dev/null 2>&1
problem=$?
if [ "$problem" != "0" ]; then
	echo "Gnuplot is required for this script."
	exit 1
fi

# My IPv4 and IPv6 test
myIPv4=$( ifconfig $iface | grep "inet end" | cut -d":" -f2 | awk '{print $1}' )
myIPv6=$( ifconfig $iface | grep inet6 | grep Global | tr -s [:blank:] % | cut -d"%" -f4 )
if [ -z "$myIPv4" -o -z "$myIPv6" ]; then
	echo "IP numbers for $iface not found. Please set."
	echo "Found:"
	echo "   IPv4: $myIPv4"
	echo "   IPv6: $myIPv6"
	exit 1
fi

echo "My interface: $iface"
echo "My IPv4: $myIPv4"
echo "My IPv6: $myIPv6"
echo ""
echo "IPv4 Server: $IPv4_server"
echo "IPv6 Server: $IPv6_server"
echo ""
echo "Packets for this experiment: $packetsForSend"
echo "Destination directory: $myLocal"
echo ""
echo -n "Press any key to continue..."
read

# ipv4
echo "Starting IPv4 ping ($packetsForSend packets), wait..."
ping -c $packetsForSend $IPv4_server > $filePingIPv4
cat $filePingIPv4 | grep "bytes from" | awk '{print $7}' | cut -d'=' -f2 > $filePingIPv4Aux
# ipv6
echo "Starting IPv6 ping ($packetsForSend packets), wait..."
ping6 -c $packetsForSend $IPv6_server > $filePingIPv6
cat $filePingIPv6 | grep "bytes from" | awk '{print $7}' | cut -d'=' -f2 > $filePingIPv6Aux

echo "Plotting graph..."
echo "
set terminal png
set ylabel 'Time (miliseconds)'
set xlabel 'Sequence of packets sent'
set size 1.0,1.0
set output '$comparisonGraph'
plot 1 notitle,\
'$filePingIPv4Aux' title 'ping using IPv4' with linespoints lc 1, \
'$filePingIPv6Aux' title 'ping using IPv6' with linespoints lc 2" | gnuplot ;

echo "File created: $comparisonGraph"
