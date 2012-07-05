##
##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.
##

BASE=/mnt/piroot
BASEETC=$(BASE)/etc

FILES=  fstab                               \
        host.conf                           \
        hostname                            \
        hosts                               \
        rc.local                            \
        resolv.conf                         \
        init.d/vcfiled                      \
        init.d/vchiq                        \
        network/interfaces                  \
        sysctl.d/raspi.conf                 \
        ld.so.conf.d/vmcs.conf              \
        modprobe.d/raspi-blacklist.conf     \
        modprobe.d/raspi.conf               \
        apt/sources.list                    \
        apt/sources.list.d/qt5pi.list       \
        apt/sources.list.d/raspbian.list    \
        apt/sources.list.d/raspi.list

all: diff md5

diff:
	@$(foreach item,$(FILES),              \
		diff -u $(BASEETC)/$(item) $(item);\
	)

md5:
	@$(foreach item,$(FILES),              \
		md5sum $(BASEETC)/$(item) &&       \
		md5sum $(item);\
	)

install:
	@$(foreach item,$(FILES),              \
		install -D -T -m644 $(item) $(BASEETC)/$(item) ;\
	)
	@chmod 755 $(BASEETC)/init.d/vchiq
	@chmod 755 $(BASEETC)/init.d/vcfiled
	@chmod 755 $(BASEETC)/rc.local


clean:

.PHONY: all clean diff md5 install

.SILENT: clean

