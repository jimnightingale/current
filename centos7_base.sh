#!/bin/bash



name="centos7base"
version="0.7"
install_packages="bash coreutils yum iputils vi"
repos="base"

outdir="/home/jamesnightingal/src/containers"
tmpfs="${outdir}/${name}/${version}"
yum_conf=/etc/yum.conf


if [ "$(id -u)" -ne "0" ]; then
    echo "Run As root"
    exit 1
fi


##!! Subscribe to correct repo on host machine.
# we'll assume we are on centos and have the base repo configured

mkdir -p ${tmpfs}

#create our devices...
mkdir -m 755 ${tmpfs}/dev
mknod -m 600 ${tmpfs}/dev/console c 5 1
mknod -m 600 ${tmpfs}/dev/initctl p
mknod -m 666 ${tmpfs}/dev/full c 1 7
mknod -m 666 ${tmpfs}/dev/null c 1 3
mknod -m 666 ${tmpfs}/dev/ptmx c 5 2
mknod -m 666 ${tmpfs}/dev/random c 1 8
mknod -m 666 ${tmpfs}/dev/tty c 5 0
mknod -m 666 ${tmpfs}/dev/tty0 c 4 0
mknod -m 666 ${tmpfs}/dev/urandom c 1 9
mknod -m 666 ${tmpfs}/dev/zero c 1 5


#do the installs using yum...
yum -c ${yum_conf} --installroot=${tmpfs} --releasever=/ --setopt=tsflags=nodocs --disablerepo=\* --enablerepo=${repos} -y install ${install_packages}

yum -c ${yum_conf} --installroot=${tmpfs} -y clean all


cat > ${tmpfs}/etc/sysconfig/network <<EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

cat > ${tmpfs}/etc/bet365-release <<EOF
NAME="CentOS 7 Base Container"
VERSION="${version}"
DATE_CREATED="$(date)"
EOF


###clear down default repos in image
rm -f ${tmpfs}/etc/yum.repos.d/CentOS*.repo
#add oour own - lets work this out - ie use the repo from which the base image was built.  KEEP IT IMMUTABLE.
cat > ${tmpfs}/etc/yum.repos.d/${name}_${version}.repo <<EOF
[base]
name=CentOS-\$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=$basearch&repo=os&infra=\$infra
baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF



# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb --keep-services "$target".
#  locales
rm -rf ${tmpfs}/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
#  docs and man pages
rm -rf ${tmpfs}/usr/share/{man,doc,info,gnome/help}
#  cracklib
rm -rf ${tmpfs}/usr/share/cracklib
#  i18n
rm -rf ${tmpfs}/usr/share/i18n
#  yum cache
rm -rf ${tmpfs}/var/cache/yum
mkdir -p --mode=0755 "${tmpfs}"/var/cache/yum
#  sln
rm -rf ${tmpfs}/sbin/sln
#  ldconfig
rm -rf ${tmpfs}/etc/ld.so.cache ${tmpfs}/var/cache/ldconfig
mkdir -p --mode=0755 ${tmpfs}/var/cache/ldconfig


#create the container image...
tar --numeric-owner -c -C ${tmpfs} . | docker import - "${name}:${version}"
docker run -i -t "${name}:${version}" /bin/bash -c 'echo success'
docker save -o "${outdir}/${name}_${version}.tar" "${name}:${version}"
