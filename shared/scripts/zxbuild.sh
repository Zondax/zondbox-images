#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxconfigure

# Build
bitbake ${IMAGE_NAME}
if [[ $? -ne 0 ]] ; then
	echo
	echo "Error building ${IMAGE_NAME}"
	echo
    exit 1
fi

IMAGE_DIR="${BUILDDIR}/${IMAGE_DIR}"
IMAGEOUTPUT_DIR=${HOME}/shared/images/${ZONDAX_CONF}

mkdir -p $IMAGEOUTPUT_DIR

echo "IMAGEDIR  : "$IMAGE_DIR
echo "IMAGENAME : "$IMAGE_NAME
echo "IMAGEOUTPUT : "$IMAGEOUTPUT_DIR

# Images are ready, apply layout and move them to the output dir
if [ "$ZONDAX_CONF" == "dk2" ]; then
	# Create image using layout
	set -e
	yes | $IMAGE_DIR/scripts/create_sdcard_from_flashlayout.sh \
		$IMAGE_DIR/flashlayout_$IMAGE_NAME/$FLASH_LAYOUT
	echo "Copy raw images to output dir"
	cp -L $IMAGE_DIR/*.raw $IMAGEOUTPUT_DIR
elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	# Create image using layout
	set -e
	yes | $IMAGE_DIR/scripts/create_sdcard_from_flashlayout.sh \
		$IMAGE_DIR/flashlayout_$IMAGE_NAME/$FLASH_LAYOUT
	echo "Copy raw images to output dir"
	cp -L $IMAGE_DIR/*.raw $IMAGEOUTPUT_DIR
elif [ "$ZONDAX_CONF" == "imx8mq" ]; then
	set -e
	# Copy raw images
	cp -L $IMAGE_DIR/*.sdcard.bz2 $IMAGEOUTPUT_DIR
	cd $IMAGEOUTPUT_DIR
	lbunzip2 -vdf *.sdcard.bz2
elif [ "$ZONDAX_CONF" == "qemu8" ]; then
	cp -L $IMAGE_DIR/bl1.bin $IMAGEOUTPUT_DIR
	cp -L $IMAGE_DIR/bl2.bin $IMAGEOUTPUT_DIR
	cp -L $IMAGE_DIR/bl31.bin $IMAGEOUTPUT_DIR
	cp -L $IMAGE_DIR/u-boot.bin $IMAGEOUTPUT_DIR/bl33.bin
	cp -L $IMAGE_DIR/core-image-minimal-qemu-optee64.cpio.gz $IMAGEOUTPUT_DIR/rootfs.cpio.gz
	cp -L $IMAGE_DIR/optee/tee-header_v2.bin $IMAGEOUTPUT_DIR/bl32.bin
	cp -L $IMAGE_DIR/optee/tee-pager_v2.bin $IMAGEOUTPUT_DIR/bl32_extra1.bin
	cp -L $IMAGE_DIR/optee/tee-pageable_v2.bin $IMAGEOUTPUT_DIR/bl32_extra2.bin
	cp -L $IMAGE_DIR/Image $IMAGEOUTPUT_DIR
elif [ "$ZONDAX_CONF" == "qemu" ]; then
	set -e
	echo "Copy raw images to output dir..."
	cp -L $IMAGE_DIR/bl1.bin $IMAGEOUTPUT_DIR
	cp -L $IMAGE_DIR/bl2.bin $IMAGEOUTPUT_DIR
	cp -L $IMAGE_DIR/u-boot.bin $IMAGEOUTPUT_DIR/bl33.bin
	cp -L $IMAGE_DIR/core-image-minimal-qemu-optee32.cpio.gz $IMAGEOUTPUT_DIR/rootfs.cpio.gz
	cp -L $IMAGE_DIR/optee/tee-header_v2.bin $IMAGEOUTPUT_DIR/bl32.bin
	cp -L $IMAGE_DIR/optee/tee-pager_v2.bin $IMAGEOUTPUT_DIR/bl32_extra1.bin
	cp -L $IMAGE_DIR/optee/tee-pageable_v2.bin $IMAGEOUTPUT_DIR/bl32_extra2.bin
	cp -L $IMAGE_DIR/zImage $IMAGEOUTPUT_DIR
fi
