Bootstrap utilities for Raspberry Pi
====================================

Debian
------

### Emulation
Launch QEMU with the SD image:

    qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel emulation/zImage-devtmpfs -m 192 -append "root=/dev/sda2 init=/bin/bash" -vga std -net nic -net user

And then:

    qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel emulation/zImage-devtmpfs -m 192 -append "root=/dev/sda2" -vga std -net nic -net user


### Post-config
Run thin on the target device:

    mount -oremount,rw /dev/sda2 /
    /debootstrap/debootstrap --second-stage

    aptitude update && aptitude dist-upgrade
    aptitude install -f
    aptitude clean && aptitude autoclean

Other tasks to perform on the target:

    dpkg-reconfigure locales
    dpkg-reconfigure tzdata
    dpkg-reconfigure keyboard-configuration

    adduser pi
    update-alternatives --config editor
    update-rc.d ssh  defaults
    update-rc.d cron remove

TODO: Update firmware, kernel and kernel modules to /lib/modules

Links
-----

