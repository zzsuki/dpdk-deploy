#!/bin/bash

# output execute log
set -e

if [ $EUID != 0 ]; then
    echo "This script must be run as root, use sudo $0 instead" 1>&2
    exit 1
fi
# verbose
set -x

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_PATH="$(dirname "$SCRIPT_PATH")"

wget ftp://zzsuki:NFS2010.WD.@10.0.34.30/trex/v2.89.tar.gz

if [ -d $HOME_PATH/trex ]; then
    rm -rf $HOME_PATH/trex
fi
mkdir $HOME_PATH/trex

tar -zxvf v2.89.tar.gz -C $HOME_PATH/trex
cp specific_cpu.yaml $HOME_PATH/trex/v2.89
