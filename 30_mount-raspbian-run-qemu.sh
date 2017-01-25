#!/bin/bash

RASPBIAN_IMAGE=$1

if [ -z "${RASPBIAN_IMAGE}" ]; then
	echo "Please provide the path to the QEMU-modified image as an argument."
	exit 1
fi


TMPDIR=/tmp/raspbian
cp ${RASPBIAN_IMAGE} ${TMPDIR}
MOUNT_DIR=${TMPDIR}/mnt
LOOP_DEV=$(sudo losetup -f -P --show ${TMPDIR}/${RASPBIAN_IMAGE})


mkdir -p ${MOUNT_DIR}

echo Mount ${LOOP_DEV}p2 ${MOUNT_DIR}
sudo mount ${LOOP_DEV}p2 -o rw ${MOUNT_DIR}

echo To unmount:
echo sudo umount ${LOOP_DEV}p2 && sudo losetup -D ${LOOP_DEV}

NETWORK="-net nic -net user"

qemu-system-arm -kernel ${TMPDIR}/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -usbdevice tablet -display sdl -append "root=/dev/sda2 panic=2 rootfstype=ext4 rw init=/bin/bash" -drive format=raw,file=${TMPDIR}/${RASPBIAN_IMAGE} ${NETWORK}
