#!/bin/bash
# Description: Set up Debian Wheezy with essential software/settings
# Author: Stephan Hochhaus <stephan@yauh.de
# Version: 0.1 initial development version
## initial install assumes no installed software 

# determine distro (so far only Debian works, but CentOS should follow sometime soon)

if [[ `cat /etc/issue` =~ "Debian" ]] ; then
	export MYDISTRO="Debian"
fi
export MYHOST=`echo $(hostname)`

echo "#########################################"
echo "# debsetupbase.sh - set up your linux system #"
echo "#########################################"
echo 


# the actual action begins here
case $MYDISTRO in
	Debian)
		# setting proper sources for Debian
		echo ## The golem appended the following sources >> /etc/apt/sources.list
		echo deb http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
		echo deb-src http://ftp.de.debian.org/debian squeeze main >> /etc/apt/sources.list
		echo deb http://packages.dotdeb.org stable all >> /etc/apt/sources.list
		wget http://www.dotdeb.org/dotdeb.gpg
		cat dotdeb.gpg | apt-key add -
		rm dotdeb.gpg
		# get the deb stuff updated
		apt-get update
		# base software packages
		apt-get -y install locales vim locate telnet ssh openssh-server exim4 tar bzip2
		# development software packages
		apt-get -y install gcc git
	*)
		echo "No idea what to do on this system"
;;
esac

# setup mail using Google Mail (GMail)

done

