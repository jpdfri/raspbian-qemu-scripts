#!/bin/bash

RASPBIAN_BUILD=2016-05-27-raspbian-jessie-lite
RASPBIAN_IMAGE=${RASPBIAN_BUILD}.img

TMPDIR=/tmp/raspbian
MOUNT_DIR=${TMPDIR}/mnt
LOOP_DEV=$(sudo losetup -f -P --show ${TMPDIR}/${RASPBIAN_IMAGE})

sudo umount ${MOUNT_DIR}
