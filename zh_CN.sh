#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

# Check System Release
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

# Set up IPV6 DNS resolution IPv4 DomainName
##mv /etc/resolv.conf /etc/resolv.conf.bak && echo -e "nameserver 2001:67c:2b0::4\nnameserver 2001:67c:2b0::6" > /etc/resolv.conf
mv /etc/resolv.conf /etc/resolv.conf.bak && echo -e "nameserver 2001:67c:2b0::4\nnameserver 2001:67c:2b0::6\nnameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

# Check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# Install some dependencies
if [ "${release}" == "centos" ]; then
	yum -y install wget ca-certificates locales localedef locales-all
else
	apt-get update 
	apt-get -y install wget ca-certificates locales locales-all
fi

# Get Word dir
dir=$(pwd)

# Change Locale
if [ "${release}" == "centos" ]; then
	localedef -v -c -i zh_CN -f UTF-8 zh_CN.UTF-8 > /dev/null 2>&1
	cd /etc
	rm -rf locale.conf
	wget https://raw.githubusercontent.com/wrtpi/zh_CN/master/locale.conf > /dev/null 2>&1
	cp locale.conf locale
	cat locale.conf >> /etc/environment

elif [ "${release}" == "debian" ]; then
	rm -rf /etc/locale.gen
	rm -rf /etc/default/locale
	rm -rf /etc/default/locale.conf
	cd /etc/
	wget https://raw.githubusercontent.com/wrtpi/zh_CN/master/locale.gen > /dev/null 2>&1
	locale-gen
	cd /etc/default/
	wget https://raw.githubusercontent.com/wrtpi/zh_CN/master/locale.conf > /dev/null 2>&1
	cp locale.conf locale
elif [ "${release}" == "ubuntu" ]; then
		rm -rf /etc/locale.gen
	rm -rf /etc/default/locale
	rm -rf /etc/default/locale.conf
	cd /etc/
	wget https://raw.githubusercontent.com/wrtpi/zh_CN/master/locale.gen > /dev/null 2>&1
 	echo "----------------------------------------------------------------------"
	echo "正在设置系统支持中文显示环境 ....................................."
  	echo "----------------------------------------------------------------------"
   	echo "Setting up system support for Chinese display environment ......"
 	echo "----------------------------------------------------------------------"
	locale-gen
	cd /etc/default/
	wget https://raw.githubusercontent.com/wrtpi/zh_CN/master/locale.conf > /dev/null 2>&1
	cp locale.conf locale
fi

# Echo Success
#clear
echo "================================================"
echo "Your VPS Language setting is changed to Chinese(Simplified)"
echo "Reconnect to your VPS to see the Chinese display effect"
echo "================================================"
echo "您的 VPS 语言设置已更改为支持中文显示（简体）"
echo "重新连接到您的 VPS 看看Linux终端的中文显示效果"
echo "================================================"
# Delete self
cd ${dir}
rm -rf zh_CN.sh
