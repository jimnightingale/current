#!/bin/bash

cd ~

name="centos7base"
version="0.4"
install_groups="Core"
install_packages="vim wget" #we wouldn't really do this
remove_packages="nc" #nc not actually in Core, just and example
repos="base"


outdir="/tmp/src/containers"
tmpfs="${outdir}/${name}/${version}"
yum_conf=/etc/yum.conf

##!! Subscribe to correct repo
# we'll assume we are on centos and have the base repo configured

mkdir -p ${tmpfs}

#create our devices...
mkdir -m 755 "${tmpfs}"/dev
mknod -m 600 "${tmpfs}"/dev/console c 5 1
mknod -m 600 "${tmpfs}"/dev/initctl p
mknod -m 666 "${tmpfs}"/dev/full c 1 7
mknod -m 666 "${tmpfs}"/dev/null c 1 3
mknod -m 666 "${tmpfs}"/dev/ptmx c 5 2
mknod -m 666 "${tmpfs}"/dev/random c 1 8
mknod -m 666 "${tmpfs}"/dev/tty c 5 0
mknod -m 66ll 6 "${tmpfs}"/dev/tty0 c 4 0
mknod -m 666 "${tmpfs}"/dev/urandom c 1 9
mknod -m 666 "${tmpfs}"/dev/zero c 1 5


#do the installs using yum...
yum_command="yum -c ${yum_conf} --installroot=${tmpfs} --releasever=/ --setopt=tsflags=nodocs --setopt=group_package_types=mandatory --disablerepo=\* --enablerepo='${repos}' -y"

eval ${yum_command} groupinstall "${install_groups}"

if [[ -n "${install_packages}" ]];
then
    eval ${yum_command} install "$install_packages}"
fi

if [[ -n "${remove_packages}" ]];
then
    eval ${yum_command} erase "${remove_packages}"
fi

yum -c "${yum_conf}" --installroot="${tmpfs}" -y clean all


cat > "${tmpfs}"/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

echo "NAME=\"CentOS 7 Base Container\"" >  "${tmpfs}"/etc/bet365-release
echo "VERSION=\"${version}\"" >> "${tmpfs}"/etc/bet365-release
echo "DATE_CREATED=\"$(date)\"" >> "${tmpfs}"/etc/bet365-release


# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb --keep-services "$target".
#  locales
rm -rf "${tmpfs}"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
#  docs and man pages
rm -rf "${tmpfs}"/usr/share/{man,doc,info,gnome/help}
#  cracklib
rm -rf "${tmpfs}"/usr/share/cracklib
#  i18n
rm -rf "${tmpfs}"/usr/share/i18n
#  yum cache
rm -rf "${tmpfs}"/var/cache/yum
mkdir -p --mode=0755 "${tmpfs}"/var/cache/yum
#  sln
rm -rf "${tmpfs}"/sbin/sln
#  ldconfig
rm -rf "${tmpfs}"/etc/ld.so.cache "${tmpfs}"/var/cache/ldconfig
mkdir -p --mode=0755 "${tmpfs}"/var/cache/ldconfig


#create the container image...
tar --numeric-owner -c -C "${tmpfs}" . | docker import - "${name}:${version}"
docker run -i -t "${name}:${version}" /bin/bash -c 'echo success'
docker save -o "${outdir}/${name}_${version}.tar" "${name}:${version}"
