#!/bin/bash

# sort the apt sources out properly
echo ## The golem appended the following sources >> /etc/apt/sources.list
echo deb http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
echo deb-src http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
echo deb http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/sources.list
echo deb-src http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/sources.list
echo deb http://packages.dotdeb.org stable all >> /etc/apt/sources.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | apt-key add -
rm dotdeb.gpg
wget http://nginx.org/keys/nginx_signing.key
cat nginx_signing.key | apt-key add -
rm nginx_signing.key

# get the deb stuff updated
apt-get update


apt-get -y install locales vim nginx imagemagick locate munin munin-node munin-plugins-extra libio-all-lwp-perl telnet python git-core g++ openssl libssl-dev make avahi-daemon avahi-discover libnss-mdns libavahi-core-dev mdadm libdb4.8-dev libcrack2-dev libssl-dev build-essential devscripts libcrypto++-dev libgcrypt11-dev avahi-utils libpam-cracklib libavahi-client-dev
cd /usr/local
wget http://sourceforge.net/projects/netatalk/files/netatalk/2.2.3/netatalk-2.2.3.tar.gz
tar -xzvf netatalk-2.2.3.tar.gz
cd netatalk-2.2.3/
./configure -enable-debian -enable-zeroconf
make && make install

echo "<?xml version=\"1.0\" standalone='no'?>" >> /etc/avahi/services/afpd.service
echo '<!--*-nxml-*-->' >> /etc/avahi/services/afpd.service
echo "<!DOCTYPE service-group SYSTEM "avahi-service.dtd">" >> /etc/avahi/services/afpd.service
echo "<service-group>" >> /etc/avahi/services/afpd.service
echo "  <name replace-wildcards=\"yes\">%h</name>" >> /etc/avahi/services/afpd.service
echo "  <service> >>" /etc/avahi/services/afpd.service
echo "    <type>_afpovertcp._tcp</type>" >> /etc/avahi/services/afpd.service
echo "    <port>548</port>" >> /etc/avahi/services/afpd.service
echo "  </service>" >> /etc/avahi/services/afpd.service
echo "  <service>" >> /etc/avahi/services/afpd.service
echo "    <type>_device-info._tcp</type>" >> /etc/avahi/services/afpd.service
echo "    <port>0</port>" >> /etc/avahi/services/afpd.service
echo "    <txt-record>model=Xserve</txt-record>" >> /etc/avahi/services/afpd.service
echo "  </service>" >> /etc/avahi/services/afpd.service
echo "</service-group>" >> /etc/avahi/services/afpd.service
/etc/avahi/services/afpd.service
echo "- -tcp -noddp -uamlist uams_dhx.so,uams_dhx2_passwd.so -nosavepassword" >> /usr/local/etc/netatalk/afpd.conf

mv /usr/local/etc/netatalk/AppleVolumes.default /usr/local/etc/netatalk/AppleVolumes.default.old
echo '/mnt/vault/media "Media" options:usedots,upriv' >> /usr/local/etc/netatalk/AppleVolumes.default
echo '/mnt/vault/timemachine "Time Machine" options:tm,usedots,upriv ' >> /usr/local/etc/netatalk/AppleVolumes.default

mkdir /mnt/vault
mount -t ext3 /dev/md0 /mnt/vault/
echo "/dev/md0        /mnt/vault      ext3    auto,users,noexec,user_xattr    0       0" >> /etc/fstab

echo "deb http://ftp.at.debian.org/debian/ sid main" >> /etc/apt/sources.list
apt-get update
ln -s /var/run /run
apt-get install minidlna