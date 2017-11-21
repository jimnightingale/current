#!/bin/bash


sudo dnf -y install wget git vim
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf check-update
sudo dnf -y install docker-ce
 
sudo dnf update -y


