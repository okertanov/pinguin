How to build the Cross sample for Raspberry Pi in Debian Squeeze
----------------------------------------------------------------

    sudo apt-get install emdebian-archive-keyring
    echo "deb http://www.emdebian.org/debian squeeze main" | sudo tee /etc/apt/sources.list.d/emdebian.list
    sudo aptitude update
    sudo aptitude search armel
    sudo aptitude search gnueabi
    sudo aptitude install gcc-4.4-arm-linux-gnueabi g++-4.4-arm-linux-gnueabi
    sudo dpkg -L gcc-4.4-arm-linux-gnueabi
    arm-linux-gnueabi-gcc --version
    cd ./src/cross
    make clean all strip
    file Cross
    qemu-arm ./Cross
    scp ./Cross pi@raspberry.lan:/home/pi/


How to build the Cross sample for native e.g. X86 platform
----------------------------------------------------------

    make clean all strip CROSS_COMPILE=""
    file Cross
    ./Cross

