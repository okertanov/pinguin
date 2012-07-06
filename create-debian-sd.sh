#!/bin/bash

##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

set -e -u

BDEVICE=/dev/sdb1
RDEVICE=/dev/sdb2

BMOUNT=/mnt/raspiboot
RMOUNT=/mnt/raspiroot

ADDITIONAL1="netbase,net-tools,ifupdown,iproute,openssh-server,ntp,ntpdate"
ADDITIONAL2="vim-nox,less,sudo,tzdata,console-data,locales,tasksel,ca-certificates"
ADDITIONAL3="x-window-system-core,fluxbox"
ADDITIONAL="$ADDITIONAL1,$ADDITIONAL2,$ADDITIONAL3"

#
# Make sure only root can run this script
#
if [ "$(\id -u)" -ne "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WARNING! It will erase your /dev/sdb (which is SD card on my system) so press Ctrl-C NOW to prevent this!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
sleep 10
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
cp ./etc/init.d/vchiq $RMOUNT/etc/init.d/

sync

umount $BDEVICE
umount $RDEVICE

echo "Done. See README.md for the post-config instructions."

