#!/bin/bash
RUI_FOLDER="raspbian-ua-netinst"
RUI_PATH=$(find ~/ -name "${RUI_FOLDER}" 2>/dev/null)
if [ -z "${RUI_PATH}" ]; then
	echo "No ${RUI_FOLDER} folder found. Please clone it from Github. Aborting."
	exit 1
fi
cd ${RUI_PATH}
echo "Cleaning previous build files."
sudo bash -c "./clean.sh"
echo "Updating packages."
./update.sh
echo "Building base files."
./build.sh
echo "Building rootfs img."
sudo bash -c "./buildroot.sh"
echo "Done."
