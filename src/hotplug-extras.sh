# Configure hotplug
mkdir -p /etc/hotplug.d/iface
cat << "EOF" > /etc/hotplug.d/iface/90-online
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_find_wan6 NET_IF6
if [ "${INTERFACE}" != "${NET_IF}" ] \
&& [ "${INTERFACE}" != "${NET_IF6}" ]
then exit 0
fi
if [ "${ACTION}" != "ifup" ] \
&& [ "${ACTION}" != "ifupdate" ]
then exit 0
fi
if [ "${ACTION}" = "ifupdate" ] \
&& [ -z "${IFUPDATE_ADDRESSES}" ] \
&& [ -z "${IFUPDATE_DATA}" ]
then exit 0
fi
hotplug-call online
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/iface/90-online
EOF
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/10-sleep
sleep 10
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/10-sleep
EOF
