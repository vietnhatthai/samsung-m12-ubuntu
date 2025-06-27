# Samsung M12 Ubuntu

# Install

```bash
apt install bc bison build-essential ca-certificates cpio curl flex git kmod libssl-dev xz-utils
apt install debootstrap qemu-user-static binfmt-support
apt install android-sdk-libsparse-utils
```

# Download initramfs

```bash
wget https://github.com/vietnhatthai/samsung-m12-ubuntu/raw/refs/heads/initramfs/initramfs -O initramfs.gz
mkdir initramfs
cd initramfs
zcat ../initramfs.gz | cpio -idmv
cd ..
```

# Build

```bash
bash make-kernel.sh
bash make-rootfs.sh
bash make-initramfs.sh
bash make-boot.sh
```

# Flash

```bash
bash flash.sh all
```
