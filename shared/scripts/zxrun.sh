#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxenv.sh

IMAGEOUTPUT_DIR=$HOME/shared/images/$ZONDAX_CONF

if [ "$ZONDAX_CONF" == "qemu8" ]; then
	exit 1
elif [ "$ZONDAX_CONF" == "qemu" ]; then
	set -e

	echo "Please use telnet to receive console output: "
	echo "    NW output > telnet 127.0.0.1 54320"
	echo "    SW output > telnet 127.0.0.1 54321"
	ROOT_NATIVE=$BUILDDIR/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/recipe-sysroot-native

	cd $IMAGEOUTPUT_DIR && $ROOT_NATIVE/usr/bin/qemu-system-arm \
		-s -S \
		-nographic \
		-machine virt,secure=on \
		-cpu cortex-a15 \
		-bios bl1.bin \
		-serial telnet:0.0.0.0:54320,server,nowait \
		-serial telnet:0.0.0.0:54321,server,nowait \
		-m 1058 \
		-d unimp -semihosting-config enable,target=native \
		-object rng-random,filename=/dev/urandom,id=rng0 \
		-device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000
fi
