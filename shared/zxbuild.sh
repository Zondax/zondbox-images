#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxenv.sh

# Build
bitbake ${IMAGE_NAME}
if [[ $? -ne 0 ]] ; then
	echo 
	echo "Error building ${IMAGE_NAME}"
	echo
    exit 1
fi

IMAGE_DIR="${BUILDDIR}/${IMAGE_DIR}"
IMAGEOUTPUT_DIR=$HOME/shared/images/

echo "IMAGEDIR  : "$IMAGE_DIR
echo "IMAGENAME : "$IMAGE_NAME
echo "IMAGEOUTPUT : "$IMAGEOUTPUT_DIR

# Images are ready, apply layout and move them to the output dir

if [ "$ZONDAX_CONF" == "dk2" ]; then
	# Create image using layout
	set -e
	$IMAGE_DIR/scripts/create_sdcard_from_flashlayout.sh \
		$IMAGE_DIR/flashlayout_$IMAGE_NAME/$FLASH_LAYOUT

	# Copy raw images
	cp $IMAGE_DIR/*.raw $$IMAGEOUTPUT_DIR
elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	# Create image using layout
	set -e
	$IMAGE_DIR/scripts/create_sdcard_from_flashlayout.sh \
		$IMAGE_DIR/flashlayout_$IMAGE_NAME/$FLASH_LAYOUT

	# Copy raw images
	cp $IMAGE_DIR/*.raw $IMAGEOUTPUT_DIR
elif [ "$ZONDAX_CONF" == "imx8qm" ]; then
	set -e
	# Copy raw images
	cp $IMAGE_DIR/* $IMAGEOUTPUT_DIR
fi
