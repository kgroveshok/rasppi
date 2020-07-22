#!/bin/sh


echo "* Install webserver"

apt-get install lighttpd

cat <<EOF >/var/www/html/index.html
<html>
<body>
<img src=astro.jpg>
</body>
</html>
EOF


apt-get install dnsmasq hostapd 
systemctl unmask hostapd
systemctl enable hostapd
#sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

cat <<EOF >>/etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.7.1/24
    nohook wpa_supplicant
EOF

mv /etc/dnsmasq.conf{,.orig}

cat <<EOF >/etc/dnsmasq.conf
interface=wlan0 # Listening interface
dhcp-range=192.168.7.2,192.168.7.20,255.255.255.0,24h
                # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.7.1
                # Alias for this router
EOF

cat <<EOF >>/etc/hostapd/hostapd.conf
country_code=GB
interface=wlan0
ssid=astrocam
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=astrocam
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

