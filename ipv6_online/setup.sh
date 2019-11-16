#!/bin/sh

IPV6_ADDRESS=
IPV6_NETMASK=
HOST_INTERFACE=
DUID=

DHCLIENT_LOCATION=`which dhclient`

# Check if user is root
if [ "$EUID" -ne 0 ]; then 
        echo "Please run as root"
        exit
fi

# Check if all variables are set
if [ -z "$IPV6_ADDRESS" ] || [ -z "$IPV6_NETMASK" ] || [ -z "$HOST_INTERFACE" ] || [ -z "$DUID" ] || [ -z "$DHCLIENT_LOCATION" ]; then
	echo "Please check if all variables are set and that dhclient is installed."
	exit
fi 

# Add IPv6 address inside networking configuration, disable SLAAC

echo "auto $HOST_INTERFACE
iface $HOST_INTERFACE inet6 static
        pre-up /sbin/sysctl -w net.ipv6.conf.eth1.autoconf=0
        address $IPV6_ADDRESS
        netmask $IPV6_NETMASK" >> /etc/network/interfaces

# Generate dhclient.conf with DUID

echo "interface \"$HOST_INTERFACE\" {
   send dhcp6.client-id $DUID;
}" > /etc/dhcp/dhclient6.conf

# Generate systemd service for sending DUID at boot

echo "[Unit]
Description=dhclient for sending DUID IPv6
Wants=network.target
Before=network.target

[Service]
Type=forking
ExecStart=$DHCLIENT_LOCATION -cf /etc/dhcp/dhclient6.conf -6 -P -v $HOST_INTERFACE

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/dhclient.service

# Enable and start the created service
systemctl daemon-reload
systemctl enable dhclient.service
systemctl start dhclient.service
