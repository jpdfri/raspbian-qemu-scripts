#!/bin/bash

NETWORK="-net nic -net user"

#RASPBIAN_BUILD=2015-11-21-raspbian-jessie
RASPBIAN_BUILD=2016-05-27-raspbian-jessie-lite
RASPBIAN_IMAGE=${RASPBIAN_BUILD}.img

TMPDIR=/tmp/raspbian

qemu-system-arm -kernel ${TMPDIR}/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -usbdevice tablet -display sdl -append "root=/dev/sda2 panic=2 rootfstype=ext4 rw init=bin/bash" -drive format=raw,file=${TMPDIR}/${RASPBIAN_IMAGE} ${NETWORK}
