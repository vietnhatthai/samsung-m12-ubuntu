current_dir=$(pwd)

export BOOT_DEPLOY_FUNCTIONS="$current_dir/boot-deploy/boot-deploy-functions.sh"
export BOOT_DEPLOY_OS="$current_dir/boot-deploy/os-customization"
export BOOT_DEPLOY_BOOT_PATH="$current_dir/kernel/boot"
export BOOT_DEPLOY_BOOT_WORKDIR="$current_dir/boot"
export BOOT_DEPLOY_MKDTBOING="$current_dir/utils/mkdtboimg.py"
export BOOT_DEPLOY_MKBOOTING="$current_dir/utils/mkbootimg/mkbootimg.py"

if [ ! -d "$tools/mkbootimg" ]; then
    git clone https://android.googlesource.com/platform/system/tools/mkbootimg ./utils/mkbootimg
fi

cp ./kernel/boot/vmlinuz-* ./boot/
cp ./kernel/boot/dtbo.img ./boot/
cp -r ./kernel/boot/dtbs ./boot/

VMLINUZ_FILE=$(find "./boot" -type f -name "vmlinuz*")

"$current_dir/boot-deploy/boot-deploy" \
    -i initramfs \
    -k $(basename $VMLINUZ_FILE) \
    -d ./boot \
    -o ./boot \
    -c ./kernel/deviceinfo/deviceinfo
