#!/bin/bash
# Update IP tables to access agent node from exchange server
ETHERNET_ID=`ip -o route get to 8.8.8.8 | awk '{print $5}'`
IP_ADDRESS=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
echo 'ETHERNET_ID ' $ETHERNET_ID
echo 'IP_ADDRESS '$IP_ADDRESS
iptables -t nat -I PREROUTING -p tcp -d $IP_ADDRESS/24 --dport 8510 -j DNAT --to-destination 127.0.0.1:8510
sysctl -w net.ipv4.conf.$ETHERNET_ID.route_localnet=1
