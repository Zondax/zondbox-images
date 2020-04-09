#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxconfigure

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

zsh
