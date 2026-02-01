# orangepi3B

https://opensource.rock-chips.com/wiki_Boot_option#rkxx_loader_vx.xx.xxx.bin

Flash and boot from Media device
从媒体设备刷机和启动
Here we introduce how to write image to different Medeia device.
这里我们介绍如何将图像写入不同的 Medeia 设备。

Get image Ready:
准备好图片：

For with SPL:   对于 SPL 的情况：
idbloader.img
u-boot.itb
boot.img or boot folder with Image, dtb and exitlinulx inside
boot.img 或 boot 文件夹，里面有 Image、dtb 和 exitlinulx
rootfs.img
For with miniloader   用 miniloader 来处理
idbloader.img
uboot.img
trust.img
boot.img or boot folder with Image, dtb and exitlinulx inside
boot.img 或 boot 文件夹，里面有 Image、dtb 和 exitlinulx
rootfs.img
 

Boot from eMMC  从 eMMC 启动
The eMMC is on the hardware board, so we need:
eMMC 在硬件板上，所以我们需要：

Get the board into maskrom mode;
把棋盘调到 maskrom 模式 ;
Connect the target to PC with USB cable;
用 USB 线将目标连接到电脑;
Flash the image to eMMC with rkdeveloptool
用 rkdeveloptool 将图像刷入 eMMC
Example commands for flash image to target.
闪光灯图像到目标的示例命令。

Flash the gpt partition to target:
将 GPT 分区刷入目标：

rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool gpt parameter_gpt.txt
For with SPL:   对于 SPL 的情况：
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool wl 0x40 idbloader.img
rkdeveloptool wl 0x4000 u-boot.itb
rkdeveloptool wl 0x8000 boot.img
rkdeveloptool wl 0x40000 rootfs.img
rkdeveloptool rd
For with miniloader   用 miniloader 来处理
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool ul rkxx_loader_vx.xx.bin
rkdeveloptool wl 0x4000 uboot.img
rkdeveloptool wl 0x6000 trust.img
rkdeveloptool wl 0x8000 boot.img
rkdeveloptool wl 0x40000 rootfs.img
rkdeveloptool rd
 



Boot from SD/TF Card  从 SD/TF 卡启动
We can write SD/TF card with Linux PC dd command very easily.
我们可以非常轻松地用 Linux PC dd 命令写入 SD/TF 卡。

Insert SD card to PC and we assume the /dev/sdb is the SD card device.
插入 SD 卡到电脑，我们假设 /dev/sdb 是 SD 卡设备。

For with SPL:   对于 SPL 的情况：
dd if=idbloader.img of=sdb seek=64
dd if=u-boot.itb of=sdb seek=16384
dd if=boot.img of=sdb seek=32768
dd if=rootfs.img of=sdb seek=262144
For with miniloader:   对于迷你装载机：
dd if=idbloader.img of=sdb seek=64
dd if=uboot.img of=sdb seek=16384
dd if=trust.img of=sdb seek=24576
dd if=boot.img of=sdb seek=32768
dd if=rootfs.img of=sdb seek=262144
In order to make sure everything has write to SD card before unpluged, recommand to run below command:
为了确保所有东西在拔掉电源前都写入 SD 卡，建议执行以下命令：

sync
Note, when using boot from SD card, need to update the kernel cmdline(which is in extlinux.conf) for the correct root value.
注意，使用 SD 卡启动时，需要更新内核 cmdline（extlinux.conf 中）以获得正确的根值。

append  earlyprintk console=ttyS2,115200n8 rw root=/dev/mmcblk1p7 rootwait rootfstype=ext4 init=/sbin/init
Write GPT partition table to SD card in U-Boot, and then U-Boot can find the boot partition and run into kernel.
在 U-Boot 中把 GPT 分区表写到 SD 卡上，然后 U-Boot 就能找到启动分区并运行内核。

gpt write mmc 0 $partitions
Boot from U-Disk  从 U 盘启动
Same as boot-from-sdcard, but please note that U-Disk only support stage 4 and 5, see Boot Stage for detail.
与从 SD 卡启动相同，但请注意 U 盘 仅支持第 4 和第 5 阶段，详情请参见启动阶段 。

If U-Disk used for stage 4 and 5, format the U-Disk in gpt format and at least 2 partitions, write boot.img and rootfs.img in those partitions;
如果使用 U-Disk 作为第 4 和第 5 阶段，请将 U-Disk 格式格式化为 gpt 格式，并至少有两个分区，在这些分区中写入 boot.img 和 rootfs.img;

if U-Dist is only used for stage 5, we can dd the rootfs.img to U-Disk device directly.
如果 U-Dist 只用于第 5 阶段 ，我们可以直接将 rootfs.img dd 发送到 U-Disk 设备。

Note, need to update the kernel cmdline(which is in extlinux.conf) for the correct root value.
注意，需要更新内核指令行（在 extlinux.conf 里）以获得正确的根值。

    append  earlyprintk console=ttyS2,115200n8 rw root=/dev/sda1 rootwait rootfstype=ext4 init=/sbin/init
