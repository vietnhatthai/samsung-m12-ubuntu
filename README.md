# Samsung M12 Ubuntu

# Install

# Build

# Download initramfs

```bash
wget https://github.com/vietnhatthai/samsung-m12-ubuntu/raw/refs/heads/initramfs/initramfs -o initramfs.gz
mkdir initramfs
cd initramfs
zcat ../initramfs.gz | cpio -idmv
cd ..
```

# Flash
