#!/bin/bash
 
logfile=/tmp/current.log
rebootfile=/root/rebootfile
completefile=/root/completefile
 
if [ ! -e $logfile ]; then
	touch $logfile
	chmod 777 $logfile
fi
 
echo "$(date +%Y-%m-%d:%H:%M:%S)  \"**ENTERING**\"" >> $logfile
 
if [ "$(whoami)" != 'root' ]; then
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"not root AND exit\"" >> $logfile
	exit
else
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"running as root\"" >> $logfile
fi

cd /root
echo "$(date +%Y-%m-%d:%H:%M:%S)  \"in $(pwd)\"" >> $logfile

if [ ! -e $completefile ]; then
	if [ ! -e $rebootfile ]; then
		echo "$(date +%Y-%m-%d:%H:%M:%S)  \"fdisk /dev/sda\"" >> $logfile
		echo -e "d\nn\n\n\n\n\nw" | fdisk /dev/sda
		sleep 2
		touch $rebootfile
		echo "$(date +%Y-%m-%d:%H:%M:%S)  \"rebooting\"" >> $logfile
		reboot
		exit
	fi
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"xfs_growfs /\"" >> $logfile
	xfs_growfs /
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"yum install -y wget\"" >> $logfile
	yum install -y wget
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"systemctl stop iptables\"" >> $logfile
	systemctl stop firewalld
	#systemctl mask iptables
	
	ExM=!
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"useradd jim\"" >> $logfile
	useradd -d /home/jim -m -p $(openssl passwd -1 jim) jim
	echo "jim ALL = (root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/jim
	echo "Defaults ${ExM}requiretty" | tee -a /etc/sudoers.d/jim
	chmod 0440 /etc/sudoers.d/jim

	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"sed -i '/^#/!s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config\"" >> $logfile
	sed -i '/^#/!s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"systemctl restart sshd.service\"" >> $logfile
	systemctl restart sshd.service

	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm\"" >> $logfile
	yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"yum install -y ansible\"" >> $logfile
	yum install -y ansible

	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"wget http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz\"" >> $logfile
	wget http://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"tar xvzf ansible-tower-setup-latest.tar.gz\"" >> $logfile
	tar xvzf ansible-tower-setup-latest.tar.gz
	
	#cd ansible-tower-setup-2.4.4
	#echo "$(date +%Y-%m-%d:%H:%M:%S)  \"in $(pwd)\"" >> $logfile
	
	#./configure
	#./setup.sh
	
	echo "$(date +%Y-%m-%d:%H:%M:%S)  \"touch $completefile\"" >> $logfile
	touch $completefile
fi
