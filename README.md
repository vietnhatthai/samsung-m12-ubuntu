# Samsung M12 Ubuntu

# Install

# Download initramfs

```bash
wget https://github.com/vietnhatthai/samsung-m12-ubuntu/raw/refs/heads/initramfs/initramfs -o initramfs.gz
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
