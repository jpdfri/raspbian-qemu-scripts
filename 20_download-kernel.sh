#!/bin/bash


# Note URL has different date in directory to build
RASPBIAN_BUILD=2016-05-27-raspbian-jessie-lite


RASPBIAN_ZIP=${RASPBIAN_BUILD}.zip
RASPBIAN_SHA1=${RASPBIAN_ZIP}.sha1
RASPBIAN_IMAGE=${RASPBIAN_BUILD}.img

QEMU_KERNEL_VERSION=4.4.34-jessie
QEMU_KERNEL_FILE="kernel-qemu-${QEMU_KERNEL_VERSION}"

RASPBIAN_URL="http://downloads.raspberrypi.org/raspbian_lite/images/${RASPBIAN_BUILD}/${RASPBIAN_ZIP}"
RASPBIAN_SHA_URL="http://downloads.raspberrypi.org/raspbian_lite/images/${RASPBIAN_BUILD}/${RASPBIAN_SHA1}"

# Hrm, not sure the best place to obtain this:
QEMU_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/${QEMU_KERNEL_FILE}"
#QEMU_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.12-jessie"

TMPDIR=/tmp/raspbian

mkdir -p ${TMPDIR}

function download_raspbian {
   # get image [resumable download]
   wget -q --show-progress -c "${RASPBIAN_URL}" -P ${TMPDIR}
}

function download_raspbian_sha {
   # get image [resumable download]
   wget -q --show-progress -c "${RASPBIAN_SHA_URL}" -P ${TMPDIR}
}

function download_qemu_kernel {
    # get kernel [resumable download]
    wget -q --show-progress -c "${QEMU_KERNEL_URL}" -P ${TMPDIR}
    ln ${TMPDIR}/${QEMU_KERNEL_FILE} ${TMPDIR}/kernel-qemu -fs
}

function do_extract_raspbian {
   unzip -u ${TMPDIR}/${RASPBIAN_ZIP} -d ${TMPDIR}
   echo "Raspbian Image: ${TMPDIR}/${RASPBIAN_IMAGE}"
}

function extract_raspbian {
if [ ! -f "${TMPDIR}/${RASPBIAN_IMAGE}" ]; then
  do_extract_raspbian
else
   # Extract if size or CRC different to one in zip
   ZIP_LOG=${TMPDIR}/${RASPBIAN_BUILD}.log
   unzip -v ${TMPDIR}/${RASPBIAN_ZIP} ${RASPBIAN_IMAGE} > ${ZIP_LOG}

   ACTUAL_SIZE=$(du -b ${TMPDIR}/${RASPBIAN_IMAGE} | cut -f1)
   EXPECTED_SIZE=$(cat ${ZIP_LOG} | sed -n 4p | cut -d' ' -f1)
   if [[ "${ACTUAL_SIZE}" != "${EXPECTED_SIZE}" ]]; then
       do_extract_raspbian
       return
   fi

   ACTUAL_CRC=$(crc32 ${TMPDIR}/${RASPBIAN_IMAGE})
   EXPECTED_CRC=$(cat ${ZIP_LOG} | sed -n 4p | cut -d' ' -f9)
   if [ ${ACTUAL_CRC} != ${EXPECTED_CRC} ]; then
       do_extract_raspbian
       return
   fi
   echo "Raspbian Image: ${TMPDIR}/${RASPBIAN_IMAGE}"
fi
}

#echo '[Download Raspbian]'
#download_raspbian
echo '[Download QEMU Kernel]'
download_qemu_kernel
#echo '[Extract Raspbian]'
#extract_raspbian
