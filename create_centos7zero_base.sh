#!/bin/bash

set -eu


name="centos7basezero"
version="0.4"
install_packages="yum coreutils bash iputils"
outdir="/home/jamesnightingal/src/containers/supermin"

existingdir=$(pwd)
  

if [ "$(id -u)" -ne "0" ]; then
  echo "Run as root."
  exit 1
fi


SUPERMIN=''
if [ ! -f /usr/bin/supermin5 ]; then
  echo "supermin5 not found."
  exit 1
fi

mkdir -p ${outdir}

cd ${outdir}
rm -rf supermin.d  centos7-zero.tar appliance.d
/usr/bin/supermin5 --prepare ${install_packages} -o supermin.d
/usr/bin/supermin5 --build --format chroot supermin.d -o appliance.d

##sort out repos?

#clear out locales
mv appliance.d/usr/share/locale/en appliance.d/tmp
mv appliance.d/usr/share/locale/en_US appliance.d/tmp
rm -rf appliance.d/usr/share/locale/*
mv appliance.d/tmp/en  appliance.d/usr/share/locale/
mv appliance.d/tmp/en_US  appliance.d/usr/share/locale/

tar --numeric-owner -c -C "${outdir}/appliance.d" . | docker import - "${name}:${version}"
docker run -i -t "${name}:${version}" /bin/bash -c 'echo success'
docker save -o "${outdir}/${name}_${version}.tar" "${name}:${version}"
