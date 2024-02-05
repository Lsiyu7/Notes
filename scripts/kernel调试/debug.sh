#!/bin/bash
set -v
qemu-system-x86_64 \
	-kernel arch/x86_64/boot/bzImage \
	-initrd \
	rootfs.img \
	-append "nokaslr console=ttyS0" \
	-s -S \
	-nographic