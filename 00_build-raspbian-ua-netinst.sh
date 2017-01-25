#!/bin/bash
# Script to automatically build raspbian-ua-netinst

# Check for the cloned repo
if [ -z $1 ]; then
	echo "Assuming \"raspbian-ua-netinst\" as the target directory to build the Raspbian netinstaller image."
	RUI_FOLDER="raspbian-ua-netinst"
else
	echo "Using "$1" as the target directory to build the Raspbian netinstaller image."
	RUI_FOLDER=$1
fi

RUI_PATH=$(find ~/ -name "${RUI_FOLDER}" 2>/dev/null)

if [ -z "${RUI_PATH}" ]; then
	echo "No ${RUI_FOLDER} folder found. Please clone raspbian-ua-netinst from Github or provide the relevant folder name as an argument. Aborting."
	exit 1
fi

cd ${RUI_PATH}

# Start building
echo "Cleaning previous build files."
sudo bash -c "./clean.sh"
echo "Updating packages."
./update.sh
echo "Building base files."
./build.sh
echo "Building rootfs img."
sudo bash -c "./buildroot.sh"
echo "Done."
