##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.

TARGET=Cross

SRC=Cross.c

HOST_SYSTEM:=$(shell uname -s)

ifndef CROSS
CROSS:=arm-linux-gnueabi-
endif

CC=$(CROSS)gcc
CXX=$(CROSS)g++
AS=$(CROSS)as
AR=$(CROSS)ar
STRIP=$(CROSS)strip
RANLIB=$(CROSS)ranlib
OBJCOPY=$(CROSS)objcopy
OBJDUMP=$(CROSS)objdump
RM=rm -f
MV=mv

MARCH=-DTARGET=native -march=native -mtune=native
COMMON_CFLAGS=-Wall -Wextra -Wcast-align -Wundef -pipe -fno-common -fomit-frame-pointer \
              -I$(./) -D_GNU_SOURCE -D_REENTRANT

C_CFLAGS=$(COMMON_CFLAGS) $(MARCH) -static -O3
CXX_CFLAGS=$(COMMON_CFLAGS) $(MARCH) -static -O3
C_LDFLAGS=
CXX_LDFLAGS=

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(C_CFLAGS) $(C_LDFLAGS) $^ -o $@

clean:
	-@$(RM) -f $(TARGET) *.o *.a *.lib *.exe *.so

.PHONY: all clean

.SILENT: clean

