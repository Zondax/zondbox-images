#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxconfigure


devtool modify ${ZONDAX_RECIPE}
if [[ $? -ne 0 ]] ; then
	echo
	echo "Error creating workspace for ${ZONDAX_RECIPE}"
	echo
    exit 1
fi

echo "-----------------------------------------------------------------------"
echo "Find local sources for ${ZONDAX_RECIPE} recipe here:"
echo "$BUILD_DIR/workspace/sources"
echo "-----------------------------------------------------------------------"
