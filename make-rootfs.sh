#!/bin/bash

echo "Debootstrap download"

sudo rm -r rootfs
sudo debootstrap --arch=arm64 focal rootfs http://ports.ubuntu.com/

echo "Mount proc, sysfs, dev, dev/pts"

sudo mount -t proc /proc rootfs/proc
sudo mount -t sysfs /sys rootfs/sys
sudo mount --bind /dev rootfs/dev
sudo mount --bind /dev/pts rootfs/dev/pts

sudo cp ./initrootfs.sh ./rootfs/root

sudo chroot rootfs /bin/bash -c "chmod +x /root/initrootfs.sh && /root/initrootfs.sh"

sudo umount rootfs/proc rootfs/sys rootfs/dev/pts rootfs/dev

mkdir -p ./boot
dd if=/dev/zero of=./boot/tmp_rootfs.img bs=1M count=2048
mkfs.ext4 -L USERDATA ./boot/tmp_rootfs.img
sudo mkdir -p /mnt/rootfs
sudo mount -o loop ./boot/tmp_rootfs.img /mnt/rootfs
sudo cp -a rootfs/* /mnt/rootfs
sudo umount /mnt/rootfs
sudo rm -r /mnt/rootfs
img2simg ./boot/tmp_rootfs.img ./boot/rootfs.img
rm ./boot/tmp_rootfs.img
