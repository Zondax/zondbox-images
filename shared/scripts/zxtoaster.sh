#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxconfigure

# # Install toaster dependencies
pip3 install -r $ROOT_DIR/poky/bitbake/toaster-requirements.txt
source toaster start webport=0.0.0.0:8000
zsh
