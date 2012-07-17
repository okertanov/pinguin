##
##    Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
##    All rights reserved.
##

BPART=/dev/sdb1
RPART=/dev/sdb2
BBASE=/mnt/raspiboot
RBASE=/mnt/raspiroot
BASEBOOT=$(BBASE)/

FILES=$(shell find . -type f -not -name Makefile -print)

all: help

help:
	-@echo
	-@echo "    This makefile is used to post-update Raspberry Pi Debian installation."
	-@echo
	-@echo "    To use: make <option>, where the options are:"
	-@echo "        mount   - mount target partitions: $(BBASE) and $(RBASE)"
	-@echo "        umount  - umount target partitions: $(BBASE) and $(RBASE)"
	-@echo "        md5     - generate checksum pairs for the local and $(BASEBOOT) files."
	-@echo "        diff    - generate diff for the local and $(BASEBOOT) files."
	-@echo "        install - populate local config to $(BASEBOOT)."
	-@echo "        clean   - clear installed (nothing for now)."
	-@echo "        help    - this help."
	-@echo

list:
	-@echo
	-@echo $(FILES)
	-@echo

diff: $(FILES)
	@$(foreach item,$(FILES),              \
		diff -u $(BASEBOOT)/$(item) $(item);\
	)

md5: $(FILES)
	@$(foreach item,$(FILES),              \
		md5sum $(BASEBOOT)/$(item) &&       \
		md5sum $(item);\
	)

install: $(FILES)
	@$(foreach item,$(FILES),              \
		install -D -T -m644 $(item) $(BASEBOOT)/$(item) ;\
	)
	@chmod 755 $(BASEBOOT)/boot.rc

mount:
	mount $(BPART) $(BBASE)
	mount $(RPART) $(RBASE)

umount:
	umount $(BPART)
	umount $(RPART)

clean:

.PHONY: all clean diff md5 install mount umount help

.SILENT: clean

