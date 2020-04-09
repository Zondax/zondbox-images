#!/usr/bin/env bash
# This script prepares the environment for Yocto builds

PATH=$PATH:$HOME/shared/scripts

# Zondax manifest
if [ "$ZONDAX_CONF" == "dk2" ]; then
	echo "Building for STM32 DK2"

	MACHINE=stm32mp1
	IMAGE_DIR=tmp/deploy/images/stm32mp1
	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv
	BSP_LAYERS=(meta-st-stm32mp meta-st-stm32mp-addons)

elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	echo "Error: Bytesatwork is not supported"

	exit 1
elif [ "$ZONDAX_CONF" == "imx8mq" ]; then
	echo "Error: MCIMX8M-EVKB is not supported"

	exit 1
elif [ "$ZONDAX_CONF" == "qemu8" ]; then
	echo "Building for QEMU v8"

	MACHINE=qemu-optee64
	IMAGE_DIR=tmp/deploy/images/qemu-optee64
	BSP_LAYERS=(meta-zondax-qemu)
elif [ "$ZONDAX_CONF" == "qemu" ]; then
	echo "Building for QEMU"

	MACHINE=qemu-optee32
	IMAGE_DIR=tmp/deploy/images/qemu-optee32
	BSP_LAYERS=(meta-zondax-qemu)
fi
function bsp_layers_current_add () {
	for i in "${BSP_LAYERS[@]}"; do bitbake-layers add-layer ${ROOT_DIR}/$i; done
}

function custom_layers_clean_all () {
	# clean cached bsp layer paths in bblayers.conf
	# we just remove one-by-one regardless if it's listed
	CUSTOM_LAYERS_FULL=(meta-zondax meta-zondax-qemu meta-st-stm32mp-addons
			    meta-st-stm32mp)
	for i in "${CUSTOM_LAYERS_FULL[@]}"; do bitbake-layers remove-layer ${ROOT_DIR}/$i; done
}

MANIFEST_BRANCH=thud
MANIFEST_URL=https://github.com/Zondax/zondbox-manifest
MANIFEST_FILE=default.xml
ENV_SOURCE="poky/oe-init-build-env build"
IMAGE_NAME=core-image-minimal
export DISTRO=zondbox-distro
export MACHINE=$MACHINE

ROOT_DIR=$HOME/shared/${DISTRO}
declare EULA_${MACHINE}=1

BUILD_DIR=$ROOT_DIR/build
echo
echo "-----------------------------------------------------------------------"
echo "Fetching \"${DISTRO}\" distribution."
echo "From ${MANIFEST_URL}/${MANIFEST_FILE}, branch/tag: ${MANIFEST_BRANCH}"
echo "The recommended development image is: ${IMAGE_NAME}"
echo "-----------------------------------------------------------------------"
echo

# Checkout and clone manifest
mkdir -p ${ROOT_DIR}
cd ${ROOT_DIR}
repo init --depth=1 --no-clone-bundle -u ${MANIFEST_URL} -b ${MANIFEST_BRANCH} -m ${MANIFEST_FILE}
repo sync -c -j$(nproc --all) --fetch-submodules --current-branch --no-clone-bundle

echo "-----------------------------------------------------------------------"
echo Setting up environment...
echo "-----------------------------------------------------------------------"

source ${ENV_SOURCE}

echo "-----------------------------------------------------------------------"
echo Adding all needed distro layers...
echo "-----------------------------------------------------------------------"

bitbake-layers add-layer ${ROOT_DIR}/meta-openembedded/meta-oe/
bitbake-layers add-layer ${ROOT_DIR}/meta-openembedded/meta-python/

echo "-----------------------------------------------------------------------"
echo Adding all needed BSP layers...
echo "-----------------------------------------------------------------------"
custom_layers_clean_all
bsp_layers_current_add

echo "-----------------------------------------------------------------------"
echo Adding Zondax meta layer...
echo "-----------------------------------------------------------------------"

bitbake-layers add-layer ${ROOT_DIR}/meta-zondax/
bitbake-layers show-layers

echo "-----------------------------------------------------------------------"
echo Packages that going to be built:
echo "-----------------------------------------------------------------------"

bitbake -g core-image-minimal && cat pn-buildlist | grep -ve "native" | sort | uniq
echo
echo "-----------------------------------------------------------------------"
echo To build run zxbuild.sh
echo Bitbake cheatsheet
echo "   bitbake <image>                    e.g. bitbake ${IMAGE_NAME}"
echo "   bitbake <recipe>                   e.g. bitbake optee-hellorustee"
echo "   bitbake <package> -c listtasks     e.g. bitbake optee-hellorustee -c listtasks"
echo "   bitbake <package> -c <taskname>    e.g. bitbake optee-hellorustee -c devshell"
echo "   bitbake-layers show-layers"
echo "   bitbake-layers show-recipes"
echo "-----------------------------------------------------------------------"
