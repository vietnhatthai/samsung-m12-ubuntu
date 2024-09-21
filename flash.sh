#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [boot|rootfs|all]"
    echo ""
    echo "Options:"
    echo "  boot    Flash only the boot image and DTBO."
    echo "  rootfs  Flash only the root filesystem image."
    echo "  all    Flash both the boot image (with DTBO) and the root filesystem image."
    echo ""
    echo "Example:"
    echo "  $0 boot     # To flash the boot image."
    echo "  $0 rootfs   # To flash the root filesystem."
    echo "  $0 all     # To flash both the boot and root filesystem."
    exit 1
}

# Check if an argument is provided
if [ $# -ne 1 ]; then
    usage
fi

# Set the flash options based on the argument
case $1 in
    boot)
        heimdall flash --BOOT ./boot/boot.img --DTBO ./boot/dtbo.img
        ;;
    rootfs)
        heimdall flash --USERDATA ./boot/rootfs.img
        ;;
    all)
        heimdall flash --BOOT ./boot/boot.img --DTBO ./boot/dtbo.img --USERDATA ./boot/rootfs.img
        ;;
    *)
        usage
        ;;
esac

echo "Flash operation for '$1' completed."
