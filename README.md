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
* /dev/sdc1    /dev/mmcblk0p1    FAT32(LBA)
* /dev/sdc2    /dev/mmcblk0p2    Linux
* /dev/sdc3    /dev/mmcblk0p3    swap?

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


Bootstrapping Debian
--------------------

### Emulation
Launch QEMU with the SD image:

    ./emu/emu-arm.sh single
    ./emu/emu-arm.sh multi

### Post-config
#### Run thin on the target device:

    mount -oremount,rw /dev/sda2 /

    /debootstrap/debootstrap --second-stage
    dpkg --configure -a

    aptitude update && aptitude dist-upgrade
    aptitude install -f
    aptitude clean && aptitude autoclean

    sudo dpkg --get-selections '*'

    vim /etc/inittab
        #Spawn a getty on Raspberry Pi serial line
        T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100

    dpkg-reconfigure locales
    dpkg-reconfigure tzdata
    dpkg-reconfigure console-data
    dpkg-reconfigure keyboard-configuration

    tasksel install standard

    update-alternatives --config editor
    update-rc.d ssh  defaults
    update-rc.d cron remove

### Swap

    sudo blkid
    dd if=/dev/zero of=/var/swapfile bs=1024 count=524288
    mkswap -L raspiswap /var/swapfile
    swapon /var/swapfile
    sudo vim /etc/fstab

#### User

    adduser pi
    ssh-keygen -t dsa
    ssh-copy-id -i .ssh/id_dsa.pub okertanov@chromebook
    sudo vim /etc/sudoers

    mkdir ~/.compose-cache

#### Firmware, kernel and kernel modules
@see https://github.com/raspberrypi/firmware

    cp ./boot/*.elf  /mnt/raspiboot/
    cp ./boot/*.bin  /mnt/raspiboot/
    cp ./boot/*.img  /mnt/raspiboot/
    cp ./boot/cmdline.txt  /mnt/raspiboot/
    cp ./boot/config.txt   /mnt/raspiboot/
    cp ./boot/boot.rc      /mnt/raspiboot/

    sudo depmod -a

#### Broadcom VC

    sudo ln -s /boot /sd

    sudo /opt/vc/sbin/install_vmcs
    sudo update-rc.d vchiq defaults
    sudo update-rc.d vcfiled defaults
    /opt/vc/bin/vcgencmd version
    /opt/vc/bin/tvservice -a

    See http://unicorn.drogon.net/vchiq
        http://elinux.org/Omxplayer

#### Network / Wi-Fi
Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter

    sudo aptitude install firmware-linux firmware-linux-free
    sudo aptitude install firmware-linux-nonfree firmware-realtek
    sudo aptitude install wireless-tools iw wpasupplicant

    sudo iwconfig

#### X11

    sudo aptitude install x-window-system-core xserver-xephyr

Window Managers
* fluxbox
* matchbox
* enlightenment

#### SMTP
citadel-mta courier-mta dma esmtp-run exim4 exim4-daemon-heavy
exim4-daemon-light lsb-invalid-mta masqmail msmtp-mta nullmailer postfix
qmail-run sendmail-bin ssmtp xmail

#### Sound
    sudo aptitude install linux-sound-base alsa-utils mplayer
    cd /opt/vc/src/hello_pi/hello_audio
    make clean all
    ./hello_audio.bin
    sudo usermod -a -G audio pi
    amixer cset numid=3 0
    speaker-test
    speaker-test -t wav
    mplayer /usr/share/sounds/alsa/*.wav

#### GSM/GPRS
    sudo aptitude install gsm-utils
    sudo gsmctl -d /dev/ttyACM0 all
    sudo gsmctl -d /dev/ttyACM0 -o dial +37125864676
    sudo gsmsendsms -d /dev/ttyACM0 +37125864676 "Hello from Raspberry Pi."
    sudo vim /etc/default/gsm-utils
    sudo vim /etc/init.d/gsm-utils

    cd gsmlib.git
    sudo aptitude install debuild fakeroot debhelper chrpath
    sudo  dpkg-buildpackage -rfakeroot -uc -b
    ls -l ../
    sudo aptitude purge gsm-utils libgsmme1c2a
    sudo dpkg -i ../libgsmme1c2a_1.10-13.2_i386.deb ../gsm-utils_1.10-13.2_i386.deb


#### Python
    sudo aptitude install python

### Useful packages

* screen
* vim-nox
* git-core
* build-essential

Links
-----

#### Software

[raspberrypi.org](http://www.raspberrypi.org/)

[element14.com/community/groups/raspberry-pi](http://www.element14.com/community/groups/raspberry-pi)

[elinux.org/R-Pi_Hub](http://elinux.org/R-Pi_Hub)

[elinux.org/RPi_Advanced_Setup](http://elinux.org/RPi_Advanced_Setup)

[elinux.org/RPi_Hardware](http://elinux.org/RPi_Hardware)

[elinux.org/RPi_Low-level_peripherals](http://elinux.org/RPi_Low-level_peripherals)

[github.com/raspberrypi](https://github.com/raspberrypi)

[github.com/Hexxeh/rpi-firmware](https://github.com/Hexxeh/rpi-firmware)

[github.com/asb/spindle](https://github.com/asb/spindle)

[raspbian.org](http://www.raspbian.org/)

[Building and Installing OpenELEC for Raspberry Pi](http://wiki.openelec.tv/index.php?title=Building_and_Installing_OpenELEC_for_Raspberry_Pi)

[debian.org/ports/arm](http://www.debian.org/ports/arm/)

[wiki.debian.org/ArmHardFloatPort](http://wiki.debian.org/ArmHardFloatPort/)

[openembedded.org](http://www.openembedded.org/)

[scratchbox.org](http://www.scratchbox.org/)

[Linaro - Open source software for ARM SoCs](http://www.linaro.org/)

[Linaro - low-cost development boards](http://www.linaro.org/engineering/getting-started/low-cost-development-boards)

[OpenEmbedded BSP layer for the Raspberry Pi](https://github.com/djwillis/meta-raspberrypi)

[Qt Embedded](http://qt-project.org/wiki/Support_for_Embedded_Linux)

[Intel NUC](http://www.extremetech.com/extreme/127903-watch-out-raspberry-pi-intel-unveils-ultra-small-next-unit-of-computing-pc)

[E17 bodhilinux.com](http://www.bodhilinux.com/)

[Raspberry Pi ARM based bare metal examples](https://github.com/dwelch67/raspberrypi)

[Lambda Pi](https://gitorious.org/lambdapi)

#### Hardware

[USB TTL Serial Cables](http://www.ftdichip.com/Products/Cables/USBTTLSerial.htm)

[FTDI Basic Breakout - 3.3V](http://www.sparkfun.com/products/9873)

[beagleboard.org/bone](http://beagleboard.org/bone)


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

