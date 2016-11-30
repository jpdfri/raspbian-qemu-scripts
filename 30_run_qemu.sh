#!/bin/bash

NETWORK="-net nic -net user"

RASPBIAN_IMAGE=$1

if [ -z ${RASPBIAN_IMAGE} ]; then
	echo "Please provide the QEMU-modified images as an argument."
	exit 1
fi

TMPDIR=/tmp/raspbian

qemu-system-arm -kernel ${TMPDIR}/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -usbdevice tablet -display sdl -append "root=/dev/sda2 panic=2 rootfstype=ext4 rw init=bin/bash" -drive format=raw,file=${TMPDIR}/${RASPBIAN_IMAGE} ${NETWORK}
