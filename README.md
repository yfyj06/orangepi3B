# orangepi3B

---
# IDBLoader 预引导加载程序
## 概述

IDBLoader（IDBlock Loader）是 Rockchip 格式的预引导加载程序，专门用于 SoC 启动时的早期初始化。它在系统启动的最早阶段工作，承担着承上启下的关键作用，是 Rockchip BootRom 与后续引导程序之间的桥梁。

---

## 作用与功能

### 核心功能

IDBLoader 作为系统启动流程中的第二阶段加载程序，其主要功能包括：

1. **启动初始化**：在 SoC 启动时执行必要的硬件初始化，为后续启动阶段奠定基础。
2. **DDR 内存初始化**：初始化 DDR SDRAM 内存控制器，为后续需要大内存的引导程序准备系统内存环境。
3. **加载下一阶段**：将后续的引导程序（如 U-Boot 或 Rockchip miniloader）加载到 DDR SDRAM 中执行。
4. **与 BootRom 交互**：作为 Rockchip BootRom 与后续引导程序的桥梁，完成从内部 SRAM 到外部 DDR SDRAM 的过渡。

### 技术定位

在 Rockchip 的启动架构中，IDBLoader 填补了 BootRom（第一阶段）和完整引导程序（第三阶段）之间的空白。由于 BootRom 容量有限且仅能在内部 SRAM 中运行，IDBLoader 的存在使得系统能够初始化更大容量的外部内存，从而加载功能完整的引导程序。

---

## 工作原理

### 组成结构

IDBLoader.img 包含三个核心组件，它们协同工作完成启动初始化任务：

| 组件名称 | 功能描述 | 执行位置 |
|---------|---------|---------|
| IDBlock 头部 | BootRom 识别的 Rockchip 特定格式头部，包含镜像元数据 | 内部 SRAM |
| DRAM 初始化程序 | 由 MaskRom 加载，在内部 SRAM 中运行，负责 DDR 控制器初始化 | 内部 SRAM |
| 下一阶段加载器 | 由 MaskRom 加载，在 DDR SDRAM 中运行，负责加载 U-Boot 或其他引导程序 | DDR SDRAM |

### 启动流程位置

在 Rockchip 的完整启动流程中，IDBLoader 位于第二阶段，其在启动序列中的位置如下表所示：

| 启动阶段 | 阶段名称 | 程序名称 | Rockchip 镜像名称 | 镜像位置（扇区） |
|---------|---------|---------|------------------|----------------|
| 1 | 主程序加载器（Primary Program Loader） | BootRom | BootRom | - |
| 2 | 次级程序加载器（Secondary Program Loader） | U-Boot TPL/SPL 或 Rockchip miniloader | idbloader.img | 0x40 |

从启动流程可以看出，IDBLoader 是从存储设备（eMMC、SD 卡或 SPI Flash）的 0x40 扇区开始加载的，这个固定位置确保了 BootRom 能够准确找到并执行预引导加载程序。

---

## 配置方法

如果使用 Rockchip 发布的加载器，不需要单独打包 idbloader.img，可以直接从 eMMC 获取或使用烧录工具加载：

```bash
# 使用 rkdeveloptool 连接到设备并下载loader
rkdeveloptool db rkxx_loader_vx.xx.bin

# 使用 rkdeveloptool 上传loader到设备
rkdeveloptool ul rkxx_loader_vx.xx.bin
```

Here we introduce how to write image to different Medeia device.
这里我们介绍如何将图像写入不同的 Medeia 设备。

Get image Ready:
准备好图片：

For with SPL:   对于 SPL 的情况：
```bash
idbloader.img
u-boot.itb
boot.img or boot folder with Image, dtb and exitlinulx inside
boot.img 或 boot 文件夹，里面有 Image、dtb 和 exitlinulx
rootfs.img
```

For with miniloader   用 miniloader 来处理
```bash
idbloader.img
uboot.img
trust.img
boot.img or boot folder with Image, dtb and exitlinulx inside
boot.img 或 boot 文件夹，里面有 Image、dtb 和 exitlinulx
rootfs.img
``` 

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

```bash
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool gpt parameter_gpt.txt
```
For with SPL:   对于 SPL 的情况：
```bash
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool wl 0x40 idbloader.img
rkdeveloptool wl 0x4000 u-boot.itb
rkdeveloptool wl 0x8000 boot.img
rkdeveloptool wl 0x40000 rootfs.img
rkdeveloptool rd
```

For with miniloader   用 miniloader 来处理
```bash
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool ul rkxx_loader_vx.xx.bin
rkdeveloptool wl 0x4000 uboot.img
rkdeveloptool wl 0x6000 trust.img
rkdeveloptool wl 0x8000 boot.img
rkdeveloptool wl 0x40000 rootfs.img
rkdeveloptool rd
```

Boot from SD/TF Card  从 SD/TF 卡启动
We can write SD/TF card with Linux PC dd command very easily.
我们可以非常轻松地用 Linux PC dd 命令写入 SD/TF 卡。

Insert SD card to PC and we assume the /dev/sdb is the SD card device.
插入 SD 卡到电脑，我们假设 /dev/sdb 是 SD 卡设备。

For with SPL:   对于 SPL 的情况：
```bash
dd if=idbloader.img of=sdb seek=64
dd if=u-boot.itb of=sdb seek=16384
dd if=boot.img of=sdb seek=32768
dd if=rootfs.img of=sdb seek=262144
```
For with miniloader:   对于迷你装载机：
```bash
dd if=idbloader.img of=sdb seek=64
dd if=uboot.img of=sdb seek=16384
dd if=trust.img of=sdb seek=24576
dd if=boot.img of=sdb seek=32768
dd if=rootfs.img of=sdb seek=262144
```
In order to make sure everything has write to SD card before unpluged, recommand to run below command:
为了确保所有东西在拔掉电源前都写入 SD 卡，建议执行以下命令：

sync
Note, when using boot from SD card, need to update the kernel cmdline(which is in extlinux.conf) for the correct root value.
注意，使用 SD 卡启动时，需要更新内核 cmdline（extlinux.conf 中）以获得正确的根值。

```bash
append  earlyprintk console=ttyS2,115200n8 rw root=/dev/mmcblk1p7 rootwait rootfstype=ext4 init=/sbin/init
```
Write GPT partition table to SD card in U-Boot, and then U-Boot can find the boot partition and run into kernel.
在 U-Boot 中把 GPT 分区表写到 SD 卡上，然后 U-Boot 就能找到启动分区并运行内核。
```bash
gpt write mmc 0 $partitions
```

## 参考资源
- **https://opensource.rock-chips.com/wiki_Boot_option#rkxx_loader_vx.xx.xxx.bin
- **Rockchip 官方开源仓库**：https://opensource.rock-chips.com/
- **Rockchip rkbin 仓库**：包含各种预编译的加载器二进制文件
- **U-Boot 官方文档**：https://docs.u-boot.org/
- **rkdeveloptool 工具**：用于与 Rockchip 设备进行烧录和调试

---

## 版本历史

| 版本 | 日期 | 更新内容 |
|-----|------|---------|
| 2.0 | 2026/2/1 | 初始版本，涵盖 IDBLoader 基本概念和配置方法 |

---

*本文档基于 Rockchip 官方开源文档整理，供参考学习使用。*
