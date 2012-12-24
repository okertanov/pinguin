#!/bin/bash

#
#   @file   build-with-ct-ng.sh
#
#   @brief  The OSX build script for the crosstool-ng toolset.
#           It solves the following crosstool-ng OSX issues:
#               - crosstool-ng build itself;
#               - crosstool-ng target buildable configuration;
#           This script builds arm-unknown-linux-gnueabi toolchain
#           for OSX Mountain Lion (10.8) to use with Raspberry Pi system.
#               gcc: 4.7.2
#               kernel: 3.6.3
#               glibc: 2.14.1
#
#   @author     Oleg Kertanov <okertanov@gmail.com>
#   @copyright  (c) 2012 Oleg Kertanov <okertanov@gmail.com>
#
#   @date   December 2012
#
#   @see    http://crosstool-ng.org/
#           and
#           http://okertanov.github.com/2012/12/24/osx-crosstool-ng
#

set -e -u

echo "0. Starting..."
echo "0.1 Requirements are:"
echo "        Xcode 4, Xcode 4 command line tools, Homebrew, approx. 8Gb free disk space"
StartBase=$(pwd)

echo "1. Installing additional brew packages"
AdditionalTools="gnu-sed binutils gawk automake libtool bash"
AdditionalTools2="https://raw.github.com/Homebrew/homebrew-dupes/master/grep.rb"
brew update
brew upgrade
brew install $AdditionalTools && true
brew install $AdditionalTools2 && true

echo "2. Creating sparse volume"
ImageName=CrossToolNG
ImageNameExt=${ImageName}.sparseimage
diskutil umount force /Volumes/${ImageName} && true
rm -f ${ImageNameExt} && true
hdiutil create ${ImageName} -volname ${ImageName} -type SPARSE -size 8g -fs HFSX
hdiutil mount ${ImageNameExt}
cd /Volumes/$ImageName

echo "3. Downloading crosstool-ng"
CrossToolVersion=crosstool-ng-1.17.0
CrossToolArchive=${CrossToolVersion}.tar.bz2
CrossToolUrl=http://crosstool-ng.org/download/crosstool-ng/${CrossToolArchive}
wget $CrossToolUrl
tar xvf $CrossToolArchive
rm -f $CrossToolArchive
cd $CrossToolVersion

echo "4. Patching crosstool-ng"
sed -i .bak '6i\
#include <stddef.h>' kconfig/zconf.y

echo "5. Configuring crosstool-ng"
./configure --enable-local \
  --with-objcopy=/usr/local/bin/gobjcopyi       \
  --with-objdump=/usr/local/bin/gobjdump        \
  --with-ranlib=//usr/local/bin/granlib         \
  --with-readelf=/usr/local/bin/greadelf        \
  --with-libtool=/usr/local/bin/glibtool        \
  --with-libtoolize=/usr/local/bin/glibtoolize  \
  --with-sed=/usr/local/bin/gsed                \
  --with-awk=/usr/local/bin/gawk                \
  --with-automake=/usr/local/bin/automake       \
  --with-bash=/usr/local/bin/bash               \
  CFLAGS="-std=c99 -Doffsetof=__builtin_offsetof"

echo "6. Building crosstool-ng"
make

echo "7. Creating ARM toolchain"
ToolChainName=pinguin-toolchain
cd ..
mkdir $ToolChainName
cd $ToolChainName

echo "8. Selecting arm-unknown-linux-gnueabi toolchain"
PATH=/usr/local/bin:$PATH ../${CrossToolVersion}/ct-ng arm-unknown-linux-gnueabi

echo "9. Cleaning toolchain"
PATH=/usr/local/bin:$PATH ../${CrossToolVersion}/ct-ng clean

echo "10. Copying toolchain configuration"
echo "10.1 Pay attantion to the following:"
echo "        Select 'Force unwind support'"
echo "        Unselect 'Link libstdc++ statically onto the gcc binary'"
echo "        Unselect 'Debugging -> dmalloc or fix its build'"
cp ${StartBase}/config-arm-unknown-linux-gnueabi ./.config

echo "11. Configuring toolchain"
# Use 'menuconfig' target for the fine tuning.
PATH=/usr/local/bin:$PATH ../${CrossToolVersion}/ct-ng oldconfig

echo "12. Building toolchain"
PATH=/usr/local/bin:$PATH ../${CrossToolVersion}/ct-ng build.4

echo "13. Done."

