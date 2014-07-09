#!/bin/bash
#-----------------------------------------------
# Script comparativo de ping com IPv4 e IPv6
# Autor: Dorival M Machado Junior (dorivaljunior gmail com)
#------------------------------------------------

filePingIPv4="/tmp/ping4.txt"
IPv4_server="192.168.100.1"

filePingIPv6="/tmp/ping6.txt"
IPv6_server="fc00:d0d0::1"

packetsForSend="20"

comparisonGraph="/tmp/v4_v6.png"


#---{begin}------
echo "Starting IPv4 ping ($packetsForSend packets), wait..."
ping -c $packetsForSend $IPv4_server > $filePingIPv4
cat $filePingIPv4 | awk '{print $7}' | cut -d'=' -f2 | egrep [0-9] > /tmp/v4.txt

echo "Starting IPv6 ping ($packetsForSend packets), wait..."
ping6 -c $packetsForSend $IPv6_server > $filePingIPv6
cat $filePingIPv6 | awk '{print $7}' | cut -d'=' -f2 | egrep [0-9] > /tmp/v6.txt

echo "Plotting graph..."
echo "
set terminal png
set ylabel 'Time (miliseconds)'
set xlabel 'Sequence of packets sent'
set size 1.0,1.0
set output '$comparisonGraph'
plot 1 notitle,\
'/tmp/v4.txt' title 'ping using IPv4' with linespoints lc 1, \
'/tmp/v6.txt' title 'ping using IPv6' with linespoints lc 2" | gnuplot ;

echo "File created: $comparisonGraph"
