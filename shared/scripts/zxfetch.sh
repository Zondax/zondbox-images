#!/usr/bin/env bash
# This script fetches/updates Zondax manifest

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxsettings

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

repo init --depth=1 --no-clone-bundle -u ${MANIFEST_URL} \
	  -b ${MANIFEST_BRANCH} -m ${MANIFEST_FILE}
repo sync -c -j$(nproc --all) --fetch-submodules \
	  --current-branch --no-clone-bundle
