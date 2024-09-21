#!/bin/bash

current_dir=$(pwd)

mkdir -p $current_dir/boot
cd $current_dir/initramfs
find . | cpio -o -H newc | gzip > "$current_dir/boot/initramfs"
cd $current_dir
