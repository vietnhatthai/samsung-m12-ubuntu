#!/bin/sh -e
#
# shellcheck shell=sh
#

# Root directory of this project (i.e. where build_kernel.sh is put)
ROOTDIR="$(dirname "$(realpath "$0")")"
# Value of "PWD" before executing this script.
OLDPWD="$PWD"

is_variant()
{
	__separator=''
	if [ -n "$1" ]
	then
		__separator='-'
	fi
	if [ -f "$ROOTDIR/arch/arm64/configs/exynos850-m12nsxx${__separator}${1}_defconfig" ]
	then
		unset __separator
		return 0
	else
		unset __separator
		return 1
	fi
}

list_variants()
{
	is_variant && echo '<default>'
	
	printf '%s\n' "$ROOTDIR"/arch/arm64/configs/exynos850-m12nsxx-*_defconfig | \
		sed 's~.*exynos850-m12nsxx-\([a-z0-9-]*\)_defconfig$~\1~g'
}

makecmd()
{
	cd "$ROOTDIR"
	make ARCH=arm64 "$@"
	cd "$OLDPWD"
}

if [ -z "$ANDROID_TOOLCHAINS" ]
then
	# physwizz toolchain path
	ANDROID_TOOLCHAINS="../toolchains"
fi

export PLATFORM_VERSION=13
export ANDROID_MAJOR_VERSION=t
export ARCH=arm64
export KCFLAGS="-mtune=cortex-a55"
export KCPPFLAGS="$KCFLAGS"

export KBUILD_BUILD_USER=linux
export KBUILD_BUILD_HOST=SM_M127F
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

# GCC toolchain
export CROSS_COMPILE="$ANDROID_TOOLCHAINS/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
# CLANG toolchain
export CLANG_PATH="$ANDROID_TOOLCHAINS/android_prebuilts_clang_host_linux-x86_clang-5484270-9.0/bin/"
# CLANG_TRIPLE toolchain
export CLANG_TRIPLE="$ANDROID_TOOLCHAINS/proton-clang-13-clang/bin/aarch64-linux-gnu-"

unset ANDROID_TOOLCHAINS

if [ "$1" = "make" ] && [ -n "$2" ]
then
  shift
	makecmd "$@"
	exit "$?"
fi

if [ "$1" = "variants" ]
then
	list_variants
	exit 1
fi

separator=''
if [ -n "$1" ] && is_variant "$1"
then
	separator='-'
fi

DEFCONFIG="exynos850-m12nsxx${separator}${1}_defconfig"

OUTPUT_DIR="../boot"

if [ -d "$DIR" ]; then
    rm -r "$OUTPUT_DIR"
fi

# Building the kernel
echo "Building the kernel:"
echo "===================="
makecmd -j"$(nproc)"

mkdir -p $OUTPUT_DIR

# Install the kernel to ./boot folder
echo
echo "Install the kernel:"
echo "===================="
makecmd -j"$(nproc)" INSTALL_PATH=$OUTPUT_DIR install

mkdir -p $OUTPUT_DIR/modules

# Install the modules to ./boot/modules folder
echo
echo "Install the modules:"
echo "===================="
makecmd -j"$(nproc)" INSTALL_MOD_PATH=$OUTPUT_DIR/modules modules_install
