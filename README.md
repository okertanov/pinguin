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

    ./emu-arm.sh single
    ./emu-arm.sh multi

### Post-config
#### Run thin on the target device:

    mount -oremount,rw /dev/sda2 /
    mount /proc

    /debootstrap/debootstrap --second-stage
    dpkg --configure -a

    passwd

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

    sudo aptitude install x-window-system-core xserver-xephyr xserver-xorg-video-fbdev xserver-xorg-video-vesa xserver-xfbdev

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
    amixer cset numid=3 0 # where n is 0=auto, 1=headphones, 2=hdmi.
    sudo vim /etc/asound.conf
        pcm.!default {
            type hw
            card 0
        }

        ctl.!default {
            type hw
            card 0
        }

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

#### Node.JS
    git clone git://github.com/joyent/node.git node.git
    cd node.git
    CFLAGS="-march=armv6j" CCFLAGS="-march=armv6j" CXXFLAGS="-march=armv6j" ./configure --prefix=./stage
    CFLAGS="-march=armv6j" CCFLAGS="-march=armv6j" CXXFLAGS="-march=armv6j" make install
    sudo mv stage /opt/node.js
    sudo vim /opt/node.js/bin/npm
    sudo mkdir /srv/www
    sudo touch /srv/www/server.js


#### Python
    sudo aptitude install python

### Useful packages

* screen
* vim-nox
* git-core
* build-essential

### Discovering a device

    arp -a
    ping 192.168.1.255
    nmap -sP 192.168.1.1/24
    networksetup -listallhardwareports

    sudo aptitude install avahi-daemon avahi-discover avahi-utils avahi-dnsconfd libnss-mdns
    avahi-browse -alr
    dns-sd -B _ssh._tcp

    open /System/Library/CoreServices/Network\ Diagnostics.app


### RaspberryPi + VNC/RDP
[My Raspberry Pi Experience: Setting Up VNC](http://myraspberrypiexperience.blogspot.com/p/setting-up-vnc.html?m=1)  
[Setting-Up Raspberry Pi for Headless Mode with X11VNC](https://codechief.wordpress.com/2013/07/17/setting-up-raspberry-pi-for-headless-mode-with-x11vnc/)  
[Documentation: VNC VIRTUAL NETWORK COMPUTING](http://www.raspberrypi.org/documentation/remote-access/vnc/)  
[Vncserver - ArchWiki](https://wiki.archlinux.org/index.php/vncserver)  

[Chicken of the VNC](http://sourceforge.net/projects/cotvnc/)  
[Chicken VNC](http://sourceforge.net/projects/chicken/)  
[leonliu/NPDesktop](https://github.com/leonliu/NPDesktop)  
[vnsea - VNC client for the iPhone and iPod Touch](https://code.google.com/p/vnsea/)  
[apenwarr/cotvnc](https://github.com/apenwarr/cotvnc)  
[LibVNC/x11vnc](https://github.com/LibVNC/x11vnc)  

[xrdp](http://www.xrdp.org/)  
[FreeRDP/FreeRDP](https://github.com/FreeRDP/FreeRDP)  

Links
-----

### New 2015
[http://blog.biicode.com/raspberry-pi-2-in-depth-biicode/](http://blog.biicode.com/raspberry-pi-2-in-depth-biicode/)

[http://wiringpi.com/](http://wiringpi.com/)

[https://wiki.ubuntu.com/Kernel/Dev/QemuARMVexpress](https://wiki.ubuntu.com/Kernel/Dev/QemuARMVexpress)

#### Software

[raspberrypi.org](http://www.raspberrypi.org/)

[element14.com/community/groups/raspberry-pi](http://www.element14.com/community/groups/raspberry-pi)

[elinux.org Development Platforms](http://elinux.org/Development_Platforms)

[elinux.org R-Pi Hub](http://elinux.org/R-Pi_Hub)

[elinux.org RPi Advanced Setup](http://elinux.org/RPi_Advanced_Setup)

[elinux.org RPi Hardware](http://elinux.org/RPi_Hardware)

[elinux.org RPi Low-level peripherals](http://elinux.org/RPi_Low-level_peripherals)

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

[Experimenting with bare metal coding on a Raspberry Pi](https://github.com/brianwiddas/pi-baremetal)

[Baking Pi - Operating Systems Development](http://www.cl.cam.ac.uk/freshers/raspberrypi/tutorials/os/)

[Lambda Pi](https://gitorious.org/lambdapi)

[Raspberry Pi webcam + ffserve](http://jeremyblythe.blogspot.co.uk/2012/05/raspberry-pi-webcam.html)

[github.com/xbianonpi/xbian](https://github.com/xbianonpi/xbian)

[Building a Raspberry Pi Cluster ](http://blog.afkham.org/2013/01/raspberry-pi-control-center.html)

[Steps to make a Raspberry Pi Supercomputer](http://www.southampton.ac.uk/~sjc/raspberrypi/)

[Hacking a Raspberry Pi into a wireless airplay speaker](http://jordanburgess.com/post/38986434391/raspberry-pi-airplay)

[github.com: RaspberryPi-BuildRoot](https://github.com/nezticle/RaspberryPi-BuildRoot)


#### Hardware

[USB TTL Serial Cables](http://www.ftdichip.com/Products/Cables/USBTTLSerial.htm)

[FTDI Basic Breakout - 3.3V](http://www.sparkfun.com/products/9873)

[beagleboard.org/bone](http://beagleboard.org/bone)

[Samsung Exynos 5 Dual Arndale Board](http://www.arndaleboard.org/wiki/index.php/Main_Page)

[Turning the Raspberry Pi Into an FM Transmitter](http://www.icrobotics.co.uk/wiki/index.php/Turning_the_Raspberry_Pi_Into_an_FM_Transmitter)

[CEC stands for Consumer Electronics Control](http://wiki.xbmc.org/index.php?title=CEC)


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
