setenv bootargs 'console=ttyS0,115200 root=PARTUUID= rw rootwait'

setenv load_addr "0x45000000"

load mmc 0:1 ${kernel_addr_r} /boot/vmlinuz
load mmc 0:1 ${ramdisk_addr_r} /boot/initramfs.img
load mmc 0:1 ${fdt_addr_r} /boot/sunxi-xxx.dtb

booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
