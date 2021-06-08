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

# echo $PROJECT_ROOT
# echo $HOME_PATH
# install dependence
apt install -y build-essential libnuma-dev python3-pyelftools 
pip3 install meson ninja

if [ -d $HOME_PATH/dpdk_backups ]; then
    echo "backup already exists"
else
    mkdir $HOME_PATH/dpdk_backups
fi

# hugepages set
## check support for 1gb
lscpu|grep pdpe1gb >> /dev/null
## config 1gb hugepages if support
if [ $? == 0 ]; then
    mv /etc/default/grub $HOME_PATH/dpdk_backups
    cp $PROJECT_ROOT/etc/default/grub /etc/default/grub
    update-grub
else
    echo "This device doesn't support 1gb hugepages config"
    exit 1
fi

# hugepage mount
mkdir /mnt/huge_1GB
mount -t hugetlbfs nodev /mnt/huge_1GB

echo "nodev /mnt/huge_1GB hugetlbfs pagesize=1GB 0 0" >> /etc/fstab

# env set up
echo "export RTE_SDK=$HOME_PATH/dpdk-stable-20.11.1" >> ~/.bashrc
echo "export RTE_TARGET=x86_64-native-linux-gcc" >> ~/.bashrc
source ~/.bashrc

# meson + ninja install dpdk
## untar dpdk source code
tar -xvf dpdk-20.11.1.tar.xz -C $HOME_PATH && cd $HOME_PATH/dpdk-stable-20.11.1
meson build
ninja -C build
ninja -C build install

# load so files hot
ldconfig

# add boot script
chmod 755 dpdk_boot_init.sh
mv dpdk_boot_init.sh /etc/init.d/ && cd /etc/init.d/
update-rc.d dpdk_boot_init.sh defaults 10000