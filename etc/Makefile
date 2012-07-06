##
##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.
##

BASE=/mnt/raspiroot
BASEETC=$(BASE)/etc

FILES=  fstab                               \
        host.conf                           \
        hostname                            \
        hosts                               \
        rc.local                            \
        resolv.conf                         \
        modules                             \
        init.d/vcfiled                      \
        init.d/vchiq                        \
        network/interfaces                  \
        sysctl.d/raspi.conf                 \
        ld.so.conf.d/vmcs.conf              \
        modprobe.d/raspi-blacklist.conf     \
        apt/sources.list                    \
        apt/sources.list.d/qt5pi.list       \
        apt/sources.list.d/raspbian.list    \
        apt/sources.list.d/raspi.list

all: help

help:
	@echo
	@echo "    This makefile is used to post-update Raspberry Pi Debian installation."
	@echo
	@echo "    To use: make <option>, where the options are:"
	@echo "        md5     - generate checksum pairs for the local and $(BASEETC) files."
	@echo "        diff    - generate diff for the local and $(BASEETC) files."
	@echo "        install - populate local config to $(BASEETC)."
	@echo "        clean   - clear installed (nothing for now)."
	@echo "        help    - this help."
	@echo

diff: $(FILES)
	@$(foreach item,$(FILES),              \
		diff -u $(BASEETC)/$(item) $(item);\
	)

md5: $(FILES)
	@$(foreach item,$(FILES),              \
		md5sum $(BASEETC)/$(item) &&       \
		md5sum $(item);\
	)

install: $(FILES)
	@$(foreach item,$(FILES),              \
		install -D -T -m644 $(item) $(BASEETC)/$(item) ;\
	)
	@chmod 755 $(BASEETC)/init.d/vchiq
	@chmod 755 $(BASEETC)/init.d/vcfiled
	@chmod 755 $(BASEETC)/rc.local

clean:

.PHONY: all clean diff md5 install help

.SILENT: clean

