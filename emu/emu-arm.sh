#!/bin/bash

##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

set -e -u

param=$1 || true 

if [ "$param" == "multi" ] ; then
    APPEND="root=/dev/sda2"
else
    APPEND="root=/dev/sda2 init=/bin/bash"
fi

echo qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel zImage-devtmpfs -m 192 -append "$APPEND" -vga std -net nic -net user
qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel zImage-devtmpfs -m 192 -append "$APPEND" -vga std -net nic -net user

