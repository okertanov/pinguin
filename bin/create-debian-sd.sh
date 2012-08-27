#!/bin/bash

##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

set -e -u

#
# Architecture
#
ARCH=armel # armhf or armel

#
# Disk and partitions
#
DEVICE=/dev/sdb
BDEVICE=${DEVICE}1
RDEVICE=${DEVICE}2

#
# Destination mount points
#
BMOUNT=/mnt/raspiboot
RMOUNT=/mnt/raspiroot

#
# Additional debootstrap packages to install
#
ADDITIONAL1="netbase,net-tools,ifupdown,iproute,openssh-server,ntp,ntpdate"
ADDITIONAL2="vim-nox,less,sudo,tzdata,console-data,locales,tasksel,ca-certificates"
ADDITIONAL3="psmisc,usbutils"
ADDITIONAL="$ADDITIONAL1,$ADDITIONAL2,$ADDITIONAL3"

#
# Make sure only root can run this script
#
if [ "$(\id -u)" -ne "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WARNING! It will erase your $DEVICE (which is SD card on my system) so press Ctrl-C NOW to prevent this!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
sleep 10
echo "Starting..."

echo "Umounting $BDEVICE"
umount $BDEVICE || true

echo "Umounting $RDEVICE"
umount $RDEVICE || true

if [ ! -d "$BMOUNT" ]; then
    echo "Creating $BMOUNT"
    mkdir $BMOUNT
fi

if [ ! -d "$RMOUNT" ]; then
    echo "Creating $RMOUNT"
    mkdir $RMOUNT
fi

echo You may cfdisk $DEVICE to initialize partitions for the first time.
cfdisk $DEVICE
blockdev --rereadpt $DEVICE

echo "Creating FAT fs on the $BDEVICE"
mkfs.vfat $BDEVICE -n "raspiboot"
mlabel -i $BDEVICE ::"raspiboot"

echo "Creating EXT4 fs on the $RDEVICE"
mkfs.ext4 $RDEVICE
tune2fs -m0 -L"raspiroot" $RDEVICE
tune2fs -o journal_data_writeback $RDEVICE
fsck $RDEVICE

sync

echo "Mounting $BDEVICE"
mount $BDEVICE $BMOUNT

echo "Mounting $RDEVICE"
mount $RDEVICE $RMOUNT

echo "Bootstraping Debian Wheezy"
/usr/sbin/debootstrap --foreign --arch $ARCH \
    --include=$ADDITIONAL \
    wheezy $RMOUNT http://ftp.de.debian.org/debian/

echo "Syncing /boot"
make -C ../fs/boot install

echo "Syncing /etc"
make -C ../fs/etc install

sync

echo "Umounting $BDEVICE"
umount $BDEVICE

echo "Umounting $RDEVICE"
umount $RDEVICE

echo "Done. See README.md for the post-config instructions."

