##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

#
# Usage:
# 			make clean all
# 			make clean all CROSS_COMPILE=""
# 			make clean all CROSS_COMPILE="arm-linux-gnieabi-"
# 			make clean all CROSS_COMPILE="ppc-unknown-gnieabi-"
#

TARGET=Cross

SRC=Cross.c

HOST_SYSTEM:=$(shell uname -s)

ifndef CROSS_COMPILE
CROSS_COMPILE?=arm-linux-gnueabi-
endif

CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
AS=$(CROSS_COMPILE)as
AR=$(CROSS_COMPILE)ar
STRIP=$(CROSS_COMPILE)strip
RANLIB=$(CROSS_COMPILE)ranlib
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
RM=rm -f
MV=mv

MARCH_ARMV6=-DTARGET=raspi -march=armv6zk -mtune=arm1176jzf-s -mfloat-abi=softfp -mfpu=vfp
MARCH_X86=-DTARGET=native -march=native -mtune=native

ifeq ($(CROSS_COMPILE),)
ARCH:=native
MARCH:=$(MARCH_X86)
else
ARCH:=arm
MARCH:=$(MARCH_ARMV6)
endif

COMMON_CFLAGS=-Wall -Wextra -Wcast-align -Wundef -pipe -fno-common -fomit-frame-pointer \
              -I./ -D_GNU_SOURCE -D_REENTRANT

C_CFLAGS=$(COMMON_CFLAGS) $(MARCH) -static -O3
CXX_CFLAGS=$(COMMON_CFLAGS) $(MARCH) -static -O3
C_LDFLAGS=-lm
CXX_LDFLAGS=-lm

all: info $(TARGET) strip

info:
	-@echo "Building $(TARGET) on $(HOST_SYSTEM) for $(ARCH) using $(CROSS_COMPILE) toolchain."

$(TARGET): $(SRC)
	$(CC) $(C_CFLAGS) $(C_LDFLAGS) $^ -o $@

strip: $(TARGET)
	$(STRIP) --strip-unneeded $<

clean:
	-@$(RM) -f $(TARGET) *.o *.a *.lib *.exe *.so

.PHONY: all info clean

.SILENT: clean

