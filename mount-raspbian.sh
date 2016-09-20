#!/bin/bash

RASPBIAN_BUILD=2016-05-27-raspbian-jessie-lite
RASPBIAN_IMAGE=${RASPBIAN_BUILD}.img

LOOP_DEV=$(sudo losetup -f -P --show ${RASPBIAN_IMAGE})

TMPDIR=/tmp/raspbian
MOUNT_DIR=${TMPDIR}/mnt

mkdir -p ${MOUNT_DIR}

echo Mount ${LOOP_DEV}p2 ${MOUNT_DIR}
sudo mount ${LOOP_DEV}p2 -o rw ${MOUNT_DIR}

echo To unmount:
echo sudo umount ${LOOP_DEV}p2 && sudo losetup -D ${LOOP_DEV}
