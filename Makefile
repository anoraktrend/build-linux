KERNEL_MAVER=v6.x
KERNEL_FULLVER=6.9.3
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/$(KERNEL_MAVER)/linux-$(KERNEL_FULLVER).tar.xz
BUSYBOX_VERSION=1.36.1
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

all: fs.tar

linux-$(KERNEL_FULLVER).tar.xz:
	wget $(KERNEL_URL)

linux-$(KERNEL_FULLVER): linux-$(KERNEL_FULLVER).tar.xz
	tar -xf linux-$(KERNEL_FULLVER).tar.xz
	cp kernel-config linux-$(KERNEL_FULLVER)/.config

bzImage: linux-$(KERNEL_FULLVER) kernel-config
	$(MAKE) -C linux-$(KERNEL_FULLVER)
	cp linux-$(KERNEL_FULLVER)/arch/x86/boot/bzImage .

busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget $(BUSYBOX_URL)

busybox-$(BUSYBOX_VERSION): busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf busybox-$(BUSYBOX_VERSION).tar.bz2

busybox: busybox-$(BUSYBOX_VERSION) bb-config
	sed '1,1i#include <sys/resource.h>' -i busybox-$(BUSYBOX_VERSION)/include/libbb.h
	cp bb-config busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) CC=musl-gcc -C busybox-$(BUSYBOX_VERSION)
	cp busybox-$(BUSYBOX_VERSION)/busybox .

fs.tar: bzImage busybox
	$(MAKE) -C filesystem

image: fs.tar gen_image.sh
	sudo ./gen_image.sh

html: doc/doc.html

doc/doc.html: README.md doc/header-css.html doc/begin-div.html doc/end-div.html
	pandoc -f markdown -t html5 README.md -o doc/doc.html -H doc/header-css.html -B doc/begin-div.html -A doc/end-div.html

.PHONY: fs.tar html
