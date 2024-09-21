#!/bin/bash

# Download toolchains

if [ -z "$ANDROID_TOOLCHAINS" ]; then
    # physwizz toolchain path
    ANDROID_TOOLCHAINS="./kernel/toolchains"
fi

# Clone aarch64-linux-android-4.9 only if the folder does not exist
if [ ! -d "$ANDROID_TOOLCHAINS/aarch64-linux-android-4.9" ]; then
    git clone https://github.com/KudProject/aarch64-linux-android-4.9.git "$ANDROID_TOOLCHAINS/aarch64-linux-android-4.9" --depth 1
fi

# Clone android_prebuilts_clang_host_linux-x86_clang-5484270 only if the folder does not exist
if [ ! -d "$ANDROID_TOOLCHAINS/android_prebuilts_clang_host_linux-x86_clang-5484270-9.0" ]; then
    git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5484270.git "$ANDROID_TOOLCHAINS/android_prebuilts_clang_host_linux-x86_clang-5484270-9.0" --depth 1
fi

# Clone proton-clang only if the folder does not exist
if [ ! -d "$ANDROID_TOOLCHAINS/proton-clang-13-clang" ]; then
    git clone https://github.com/kdrag0n/proton-clang.git "$ANDROID_TOOLCHAINS/proton-clang-13-clang" --depth 1
fi

# Define the Samsung kernel ID and file URL
SAMSUNG_KERNEL_ID="015d55dfaa2916ad64ef97e8d4cd7f860d6a4e96"
KERNEL_URL="https://github.com/SpacingBat3/android_kernel_samsung-m127f_a13/archive/$SAMSUNG_KERNEL_ID.tar.gz"

# Set the default Samsung kernel path if not provided
if [ -z "$SAMSUNG_KERNEL" ]; then
    SAMSUNG_KERNEL="./kernel/samsung_kernel"
fi

PATCH_DIR="./kernel/patches"
CONFIG_FILE="./kernel/config/config-samsung-m12.aarch64"
BUILD_FILE="./kernel/build/build_kernel.sh"

# Set the default Samsung kernel path if not provided
if [ -d "$SAMSUNG_KERNEL" ]; then
    rm -rf "$SAMSUNG_KERNEL"
fi

# Create the directory if it doesn't exist
mkdir -p "$SAMSUNG_KERNEL"

# Check if the kernel directory exists
if [ ! -d "$SAMSUNG_KERNEL" ]; then
    echo "Kernel directory not found!"
    exit 1
fi

# Download the kernel tarball
wget -O "$SAMSUNG_KERNEL/$SAMSUNG_KERNEL_ID.tar.gz" "$KERNEL_URL"

# Extract the downloaded tarball
tar -xzf "$SAMSUNG_KERNEL/$SAMSUNG_KERNEL_ID.tar.gz" -C "$SAMSUNG_KERNEL" --strip-components=1

# Clean up the downloaded tarball
rm "$SAMSUNG_KERNEL/$SAMSUNG_KERNEL_ID.tar.gz"

# Apply all patches from the patches directory
for patch in "$PATCH_DIR"/*.patch; do
    echo "Applying patch: $patch"
    patch -d "$SAMSUNG_KERNEL" -p1 <"$patch"
    if [ $? -ne 0 ]; then
        echo "Failed to apply patch: $patch"
        exit 1
    fi
done

# Copy the config file to .config in the kernel directory
cp "$CONFIG_FILE" "$SAMSUNG_KERNEL/.config"
if [ $? -eq 0 ]; then
    echo "Config file copied to .config"
else
    echo "Failed to copy config file"
    exit 1
fi

# Copy the build file to build_kernel.sh in the kernel directory
cp "$BUILD_FILE" "$SAMSUNG_KERNEL/build_kernel.sh"
if [ $? -eq 0 ]; then
    echo "Build file copied to build_kernel.sh"
else
    echo "Failed to copy build file"
    exit 1
fi

# Save the current directory
current_dir=$(pwd)
MKDTBOING="$current_dir/utils/mkdtboimg.py"
AVBTOOL="$current_dir/utils/avbtool.py"

# Change to the target directory
cd ./kernel/samsung_kernel || exit

# Run the build script
bash build_kernel.sh

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Returning to the original directory."
    cd "$current_dir" || exit
else
    echo "Build completed successfully."
fi

mv "arch/arm64/boot/dts/exynos/exynos3830.dtb" ./dtb
python3 $MKDTBOING create "arch/arm64/boot/dts/exynos/exynos3830.dtb" dtb --custom1=0xff
mkdir -p ../boot/dtbs
install -Dm644 "arch/arm64/boot/dts/exynos/exynos3830.dtb" "../boot/dtbs/exynos3830.dtb"

openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:4096
python3 $MKDTBOING create mergeddtbos "arch/arm64/boot/dts/samsung/m12/m12_eur_open_w00_r00.dtbo" "arch/arm64/boot/dts/samsung/m12/m12_eur_open_w00_r01.dtbo" --custom0=0x1 --custom1=0x20

python3 $AVBTOOL add_hash_footer \
    --partition_name dtbo \
    --partition_size 8388608 \
    --image ./mergeddtbos \
    --algorithm SHA256_RSA4096 \
    --key private_key.pem \
    --rollback_index 0 \
    --rollback_index_location 0 \
    --hash_algorithm sha256 \
    --salt $(sha256sum ./mergeddtbos | awk '{ print $1 }')

install -Dm644 "./mergeddtbos" "../boot/dtbo.img"

# Return to the original directory
cd "$current_dir" || exit
