#!/bin/bash

##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

set -e -u

param=$1 || true

if [ "$param" == "multi" ] ; then
    APPEND="noinitrd rootwait root=/dev/mmcblk0p2 rootfstype=ext4 console=ttyAMA0 debug"
else
    APPEND="noinitrd rootwait root=/dev/mmcblk0p2 rootfstype=ext4 console=ttyAMA0 debug init=/bin/bash"
fi

#
# Kernels
# See:
#   http://ftp.debian.org/debian/dists/wheezy/main/installer-armhf
#   http://ports.ubuntu.com/dists/trusty/
#
#KERNEL=kernel/zImage-devtmpfs
#KERNEL=kernel/zImage-versatile-2.6.24-rc7.armv5tel
#KERNEL=kernel/zImage-qemu-versatile-3.0.8-4.fc17.armv5tel
#KERNEL=kernel/vmlinuz-3.2.0-4-vexpress
#KERNEL=kernel/vmlinuz-sid-armhf
KERNEL=kernel/vmlinuz-trusty-net

#qemu-system-arm -nographic -M versatilepb -drive file=/dev/sdb,if=scsi,index=0,media=disk -kernel $KERNEL -m 192 -append "$APPEND" -net nic -net user
qemu-system-arm -nographic -M vexpress-a9 -cpu cortex-a9 -drive file=/dev/sdb,if=sd,index=0,media=disk -kernel $KERNEL -m 192 -append "$APPEND" -net nic -net user

