Bootstrap utilities for Raspberry Pi
====================================

General Info
------------

### Co-creators
* Eben Upton
* Peter Lomas

### Hardware
* SOC: Broadcom BCM2835 (CPU + GPU + SDRAM)
* CPU: 700 MHz ARM11 ARM1176JZF-S core (ARMv6 architecture, VFP)
* GPU: Broadcom VideoCore IV,OpenGL ES 2.0,OpenVG 1080p30 H.264 high-profile encode/decode
* SDRAM: 256MiB
* Video: Composite RCA and HDMI (not at the same time)
* Audio: outputs: 3.5mm jack TRS, HDMI
* USB 2.0 ports: 2 (via integrated USB hub)
* Storage: SD / MMC / SDIO card slot
* Network: LAN9512 10/100 wired Ethernet RJ45
* Peripherals: 8 GPIO, SPI, I2C, I2S, UAR, DSI interface, CSI-2 interface, ARM JTAG
* Power: 700mA, (3.5 Watt) 5V via Micro USB or GPIO header
* Test Points: TP1 and TP2 giving access to +5V and GND respectively
* 5 Status LEDs: D5(Green), D6(Red), D7(Green), D8(Green), D9(Yellow)
* Size: 85.60mm x 53.98mm x 25mm
* Weight: 40g
* PCB: 6 layers

### Disk layout & partitions
    /dev/sdc1   FAT32(LBA)
    /dev/sdc2   Linux

### Boot partition files
* bootcode.bin : 2nd stage bootloader, starts with SDRAM disabled
* loader.bin : 3rd stage bootloader, starts with SDRAM enabled
* start.elf: The GPU binary firmware image, provided by the foundation.
* kernel.img: The OS kernel to load on the ARM processor. Normally this is Linux - see instructions for compiling a kernel.
* cmdline.txt: Parameters passed to the kernel on boot.

### Optional files
* config.txt: A configuration file read by the GPU. Use this to override set the video mode, alter system clock speeds, voltages, etc.
* vlls directory: Additional GPU code, e.g. extra codecs. Not present in the initial release.

### Additional files supplied by the foundation
* kernel\_emergency.img : kernel with busybox rootfs. You can use this to repair the main linux partition using e2fsck if the linux partition gets corrupted.
* arm128\_start.elf : 128M ARM, 128M GPU split (use this for heavy 3D work, possibly also required for some video decoding)
* arm192\_start.elf : 192M ARM, 64M GPU split (this is the default)
* arm224\_start.elf : 224M ARM, 32M GPU split (use this for Linux only with no 3D or video processing. Its enough for the 1080p framebuffer, but not much else)

### Emulation
    qemu-system-arm -kernel kernel-qemu -cpu arm1136-r2 -M versatilepb -no-reboot -append "root=/dev/sda2 panic=1" -hda debian6-19-04-2012.img -m 512


Bootstrapping Debian
--------------------

### Emulation
Launch QEMU with the SD image:

    qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel emulation/zImage-devtmpfs -m 192 -append "root=/dev/sda2 init=/bin/bash" -vga std -net nic -net user

And then:

    qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda /dev/sdb -kernel emulation/zImage-devtmpfs -m 192 -append "root=/dev/sda2" -vga std -net nic -net user

### Post-config
#### Run thin on the target device:

    mount -oremount,rw /dev/sda2 /
    /debootstrap/debootstrap --second-stage

    aptitude update && aptitude dist-upgrade
    aptitude install -f
    aptitude clean && aptitude autoclean

#### Other tasks to perform on the target:

    dpkg-reconfigure locales
    dpkg-reconfigure tzdata
    dpkg-reconfigure console-data
    dpkg-reconfigure keyboard-configuration

    tasksel install standard

    adduser pi
    update-alternatives --config editor
    update-rc.d ssh  defaults
    update-rc.d cron remove

#### Firmware, kernel and kernel modules
@see https://github.com/raspberrypi/firmware

    cp ./boot/*.elf  /mnt/raspiboot/
    cp ./boot/*.bin  /mnt/raspiboot/
    cp ./boot/*.img  /mnt/raspiboot/
    cp ./boot/cmdline.txt  /mnt/raspiboot/
    cp ./boot/config.txt   /mnt/raspiboot/
    cp ./boot/boot.rc      /mnt/raspiboot/

#### Broadcom VC
    vim /etc/modules or modules.d...
        vchiq
        snd_bcm2835

    See http://unicorn.drogon.net/vchiq
        http://elinux.org/Omxplayer

Links
-----
[raspberrypi.org](http://www.raspberrypi.org/)

[element14.com/community/groups/raspberry-pi](http://www.element14.com/community/groups/raspberry-pi)

[elinux.org/R-Pi_Hub](http://elinux.org/R-Pi_Hub)

[elinux.org/RPi_Advanced_Setup](http://elinux.org/RPi_Advanced_Setup)

[http://elinux.org/RPi_Hardware](http://elinux.org/RPi_Hardware)

[github.com/raspberrypi](https://github.com/raspberrypi)

[github.com/Hexxeh/rpi-firmware](https://github.com/Hexxeh/rpi-firmware)

[raspbian.org](http://www.raspbian.org/)

[Building and Installing OpenELEC for Raspberry Pi](http://wiki.openelec.tv/index.php?title=Building_and_Installing_OpenELEC_for_Raspberry_Pi)

[debian.org/ports/arm](http://www.debian.org/ports/arm/)

[openembedded.org](http://www.openembedded.org/)

[scratchbox.org](http://www.scratchbox.org/)

[Linaro - Open source software for ARM SoCs](http://www.linaro.org/)

[Linaro - low-cost development boards](http://www.linaro.org/engineering/getting-started/low-cost-development-boards)

[OpenEmbedded BSP layer for the Raspberry Pi](https://github.com/djwillis/meta-raspberrypi)

[Qt Embedded](http://qt-project.org/wiki/Support_for_Embedded_Linux)

[Intel NUC](http://www.extremetech.com/extreme/127903-watch-out-raspberry-pi-intel-unveils-ultra-small-next-unit-of-computing-pc)

[E17 bodhilinux.com](http://www.bodhilinux.com/)


Ideas
-----
* Media Player
* Emulation box
* Integration Projects
* Controler for a CNC machine
* Timelapse Photogrophy
* Distributed Computing / Cluster
* Weather Ballon
* Augmented Reality
* Car PC (carputer)
* Robotics
* Online Radio Station
* Packet Radio Device
* GPS Device
* WWW Server
* AirTunes server
* NAS
* NAT/Firewall
* Kiosk
* HTPC
* Set-top box
* Monitoring panel (net, commits, bugs, downloads, etc)
* Computer education
* Buddha Machine
* BootToXYZ
* WebGL experiments machine
* Aerial Panorama machine
* Home alarm / Automation system
* IP-Cams controller & NVR system
* SCADA, Sensors monitoring service & web notify
* Mail client/robot via fetchmail/procmail
* Weather station

