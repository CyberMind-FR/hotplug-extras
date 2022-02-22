# hotplug-extras
hotplug-extras.sh

REFS:
- https://openwrt.org/license
- https://openwrt.org/docs/guide-user/advanced/hotplug_extras

====== Hotplug extras ======
{{section>meta:infobox:howto_links#cli_skills&noheader&nofooter&noeditbutton}}

===== Introduction =====
  * This instruction extends the functionality of [[docs:guide-user:base-system:hotplug|Hotplug]].
  * Follow the [[docs:guide-user:advanced:hotplug_extras#automated|automated]] section for quick setup.

===== Features =====
  * Run scripts at startup when the network is online.

===== Implementation =====
  * Rely on [[https://github.com/openwrt/openwrt/blob/master/package/base-files/files/lib/functions/network.sh|network functions]] to identify WAN interface.
  * Use [[docs:guide-user:base-system:hotplug|Hotplug]] to detect WAN connectivity and trigger network dependent scripts.
  * Process subsystem-specific scripts with [[https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/hotplug-call|hotplug-call]].
  * Delay script invocation with [[man>sleep(1)|sleep]] to work around tunneled connections.
  * Write and read non-interactive logs with [[docs:guide-user:base-system:log.essentials|Syslog]] for troubleshooting.

===== Instructions =====
```
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
```

===== Examples =====
```
# Example script
cat << "EOF" > /etc/hotplug.d/online/30-example
logger -t hotplug online
EOF
reboot
```

===== Automated =====
```
uclient-fetch -O hotplug-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/hotplug_extras?codeblock=0"
. ./hotplug-extras.sh
```
