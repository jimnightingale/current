#!/bin/bash


sudo dnf -y install wget git vim
sudo dnf -y install dnf-plugins-core
#sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
echo "[docker-ce-stable]" | sudo tee /etc/yum.repos.d/docker-ce.repo
echo "name=Docker CE Stable - \$basearch" | sudo tee -a /etc/yum.repos.d/docker-ce.repo
echo "#baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable" | sudo tee -a /etc/yum.repos.d/docker-ce.repo
echo "baseurl=https://download.docker.com/linux/fedora/26/x86_64/stable" | sudo tee -a /etc/yum.repos.d/docker-ce.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/docker-ce.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/docker-ce.repo
echo "gpgkey=https://download.docker.com/linux/fedora/gpg" | sudo tee -a /etc/yum.repos.d/docker-ce.repo 



sudo dnf check-update
sudo dnf -y install docker-ce
 
sudo dnf update -y


