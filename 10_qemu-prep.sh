#!/usr/bin/env bash
# Script to modify a raspbian-ua-netinst image to run in QEMU
# Original work by Github user dhanar10, updated by Github user diederikdehaas et.al.
# https://github.com/debian-pi/raspbian-ua-netinst/issues/34#issuecomment-58807067

# Function definitions
check_tool()
{
	if [ -z "$(which "$1")" ]; then
		echo "The required tool \"${1}\" was not found. Abort."
		exit 1
	fi	
}

if [ "$(id -u)" != 0 ]; then
	echo "Must be run as root. Aborting"
	exit 1
fi

SCRIPT_NAME="$(basename "$0")"

if [ "$#" -eq 0 ]; then
	echo "Usage: $SCRIPT_NAME [RASPBIAN_NETINST_FOLDER_NAME] DISK_IMAGE"
	exit 1
fi

# Path to rpitor folder
RPI_TOR=$(find / -name "rpitor" 2>/dev/null)

# Check for the cloned raspbian-ua-netinst repo
if [ -z "$2" ]; then
	echo "Assuming \"raspbian-ua-netinst\" as the target directory to build the Raspbian netinstaller image."
	RUI_FOLDER="raspbian-ua-netinst"
	DISK_IMAGE="$1"
else
	echo "Using "$1" as the target directory to build the Raspbian netinstaller image."
	RUI_FOLDER="$1"
	DISK_IMAGE="$2"
fi

RUI_PATH=$(find / -name "${RUI_FOLDER}" 2>/dev/null)

if [ -z "${RUI_PATH}" ]; then
	echo "No ${RUI_FOLDER} folder found. Please clone raspbian-ua-netinst from Github or provide the relevant folder name as an argument. Aborting."
	exit 1
fi

cd ${RUI_PATH}

check_tool "qemu-img"
check_tool "kpartx"

TEMP_DIR="$(mktemp -d $(pwd)/${SCRIPT_NAME}.XXXXXXXX)"

qemu-img resize ${DISK_IMAGE} 486M

LOOP_DEVICE_NAME="$(kpartx -avs "${DISK_IMAGE}" | grep -o 'loop[0-9]' | head -n 1)"

mkdir -p "$TEMP_DIR/installer"
mkdir -p "$TEMP_DIR/disk-image/boot"

mount "/dev/mapper/${LOOP_DEVICE_NAME}p1" "$TEMP_DIR/disk-image/boot"

(cd "$TEMP_DIR/disk-image/boot" && gunzip installer-rpi1.cpio.gz)
(cd "$TEMP_DIR/installer" && cpio -iv < ../"disk-image/boot/installer-rpi1.cpio")
(cd "$TEMP_DIR/installer" && sed -i '/^bootdev=/s|/dev/mmcblk0|/dev/sda|' "etc/init.d/rcS")
(cd "$TEMP_DIR/installer" && sed -i '/^bootpartition=/s|/dev/mmcblk0p1|/dev/sda1|' "etc/init.d/rcS")
(cd "$TEMP_DIR/installer" && sed -i '/^rootdev=/s|/dev/mmcblk0|/dev/sda|' "etc/init.d/rcS")
(cd "$TEMP_DIR/installer" && sed -i '/^rootpartition=/s|$|/dev/sda2|' "etc/init.d/rcS")
(cd "$TEMP_DIR/installer" && find . | cpio -H newc -ov > ../"installer-qemu.cpio")
rm -rf "$TEMP_DIR/installer"

mv "$TEMP_DIR/installer-qemu.cpio" .

cat << EOF > "$TEMP_DIR/disk-image/boot/installer-config.txt"
packages=whiptail,pppoeconf,git
bootsize=+64M
EOF

cat << EOF >> "$TEMP_DIR/disk-image/boot/post-install.txt"
sed -i 's|/dev/sda2|/dev/mmcblk0p2|' "/rootfs/boot/cmdline.txt"
sed -i 's|/dev/sda1|/dev/mmcblk0p1|' "/rootfs/etc/fstab"
sed -i 's|/dev/sda2|/dev/mmcblk0p2|' "/rootfs/etc/fstab"
echo "gpu_mem=16" >> "/rootfs/boot/config.txt"
EOF

cat ${RPI_TOR}/scripts/setup-image/post-install.txt >> "$TEMP_DIR/disk-image/boot/post-install.txt"

sync

umount "$TEMP_DIR/disk-image/boot"

kpartx -d "$DISK_IMAGE" > "/dev/null"

rm -rf "$TEMP_DIR"
