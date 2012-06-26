#!/bin/bash

set -e -u

BDEVICE=/dev/sdb1
RDEVICE=/dev/sdb2

BMOUNT=/mnt/piboot
RMOUNT=/mnt/piroot

ADDITIONAL1="netbase,net-tools,ifupdown,iproute,openssh-server,ntpdate"
ADDITIONAL2="vim-nox,less,sudo,locales"
ADDITIONAL3="x-window-system-core,fluxbox"
ADDITIONAL="$ADDITIONAL1,$ADDITIONAL2,$ADDITIONAL3"

#
# Make sure only root can run this script
#
if [ "$(\id -u)" -ne "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Starting..."

ls /mnt

umount $BDEVICE
umount $RDEVICE

if [ ! -d "$BMOUNT" ]; then
    mkdir $BMOUNT
fi

if [ ! -d "$RMOUNT" ]; then
    mkdir $RMOUNT
fi

echo cfdisk /dev/sdb

mlabel -i $BDEVICE ::"raspiboot"

mkfs.ext4 $RDEVICE
tune2fs -m0 -L"raspiroot" $RDEVICE
tune2fs -o journal_data_writeback $RDEVICE
fsck $RDEVICE

sync

mount $BDEVICE $BMOUNT
mount $RDEVICE $RMOUNT

/usr/sbin/debootstrap --foreign --arch armel \
    --include=$ADDITIONAL \
    wheezy $RMOUNT http://ftp.de.debian.org/debian/

sync

cp ./etc/hosts        $RMOUNT/etc/
cp ./etc/hostname     $RMOUNT/etc/
cp ./etc/resolv.conf  $RMOUNT/etc/
cp ./etc/fstab        $RMOUNT/etc/
cp ./etc/network/interfaces $RMOUNT/etc/network/
cp ./etc/apt/sources.list   $RMOUNT/etc/apt/

sync

umount $BDEVICE
umount $RDEVICE

echo
echo Launch QEMU with the SD image:
echo
echo qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel ~/Downloads/zImage-devtmpfs -m 192 -append "root=/dev/sda2 init=/bin/bash" -vga std -net nic -net user
echo qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel ~/Downloads/zImage-devtmpfs -m 192 -append "root=/dev/sda2" -vga std -net nic -net user
echo

echo
echo Run thin on the target device:
echo
echo mount -oremount,rw /dev/sda2 /
echo /debootstrap/debootstrap --second-stage
echo "aptitude update && aptitude dist-upgrade"
echo aptitude install -f
echo "aptitude clean && aptitude autoclean"
echo

echo
echo Other tasks to perform on the target:
echo
echo dpkg-reconfigure locales
echo dpkg-reconfigure tzdata
echo adduser pi
echo update-alternatives --config editor
echo update-rc.d ssh  defaults
echo update-rc.d cron remove
echo TODO: Update firmware and kernel
echo TODO: Copy kernel modules to /lib/modules
echo

echo "Done."

