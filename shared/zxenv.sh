#!/usr/bin/env bash
# This scripts prepares the environment for Yocto builds

# Zondax manifest

if [ "$ZONDAX_CONF" == "dk2" ]; then
	echo "Using STM32 DK2 manifest"

	DISTRO=openstlinux-weston
	MACHINE=stm32mp1

	BRANCH_NAME=refs/tags/zondax-meta-20-02-19
	MANIFEST_URL=https://github.com/Zondax/oe-manifest.git

	IMAGE_DIR=tmp-glibc/deploy/images/stm32mp1
	IMAGE_NAME=st-image-weston

	ENV_SOURCE=layers/meta-st/scripts/envsetup.sh
	MANIFEST_FILE=default.xml

	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv
elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	echo "Using Bytesatwork manifest"

	DISTRO=poky-bytesatwork
	MACHINE=bytedevkit

	BRANCH_NAME=refs/tags/$zondax-meta-bytesatwork
	MANIFEST_URL=https://github.com/Zondax/oe-manifest.git

	# for some reason after sourcing MACHINE is empty
	IMAGE_DIR=tmp/deploy/images/bytedevkit
	IMAGE_NAME=devbase-image-bytesatwork

	ENV_SOURCE="setup-environment build"
	MANIFEST_FILE=bytesatwork.xml

	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-bytedevkit.tsv
	# Scripts expects just simple EULA var set
	EULA=1
elif [ "$ZONDAX_CONF" == "imx8mq" ]; then
	echo "Using MCIMX8M-EVKB manifest"

	DISTRO=fsl-imx-wayland
	MACHINE=imx8mqevk

	BRANCH_NAME=imx-linux-sumo
	MANIFEST_URL=https://source.codeaurora.org/external/imx/imx-manifest

	# for some reason after sourcing MACHINE is empty
	IMAGE_DIR=tmp/deploy/images/imx8qm
	IMAGE_NAME=fsl-image-qt5-validation-imx

	ENV_SOURCE="./fsl-setup-release.sh -b bld-wayland"
	MANIFEST_FILE=imx-4.14.98-2.3.1.xml

	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-bytedevkit.tsv
	# Scripts expects just simple EULA var set
	EULA=1
fi

ROOT_DIR=$HOME/shared/${IMAGE_NAME}
declare EULA_${MACHINE}=1

BUILD_DIR=$ROOT_DIR/build
echo
echo "-----------------------------------------------------------------------"
echo "Fetching \"${DISTRO}\" distribution."
echo "From ${MANIFEST_URL}/${MANIFEST_FILE}, tag: ${TAG_NAME}"
echo "The recommended development image is: ${IMAGE_NAME}"
echo "-----------------------------------------------------------------------"
echo

# Checkout and clone manifest
mkdir -p ${ROOT_DIR}
cd ${ROOT_DIR}
repo init --depth=1 --no-clone-bundle -u ${MANIFEST_URL} -b ${BRANCH_NAME} -m ${MANIFEST_FILE}
repo sync -c -j$(nproc --all) --fetch-submodules --current-branch --no-clone-bundle

echo "-----------------------------------------------------------------------"
echo Setting up environment:
echo "-----------------------------------------------------------------------"

source ${ENV_SOURCE}

echo "-----------------------------------------------------------------------"
echo Adding Zondax Meta layer:
echo "-----------------------------------------------------------------------"

git clone https://github.com/Zondax/meta-zondax.git $HOME/shared/meta-zondax
bitbake-layers add-layer $HOME/shared/meta-zondax
bitbake-layers show-layers
