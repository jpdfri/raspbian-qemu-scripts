#!/bin/bash
RUN_PATH="../raspbian-ua-netinst"
echo "Cleaning previous build files."
sudo bash -c "${RUN_PATH}/clean.sh"
echo "Updating packages."
./${RUN_PATH}/update.sh
echo "Building base files."
./${RUN_PATH}/build.sh
echo "Building rootfs img."
sudo bash -c "${RUN_PATH}/buildroot.sh"
echo "Done."
