# orangepi3B

https://opensource.rock-chips.com/wiki_Boot_option#rkxx_loader_vx.xx.xxx.bin


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

### 方法一：从 Rockchip 发布加载器获取

此方法适用于 eMMC 启动场景，使用 Rockchip 官方预编译的二进制加载器文件。

#### 操作步骤

如果使用 Rockchip 发布的加载器，不需要单独打包 idbloader.img，可以直接从 eMMC 获取或使用烧录工具加载：

```bash
# 使用 rkdeveloptool 连接到设备并下载loader
rkdeveloptool db rkxx_loader_vx.xx.bin

# 使用 rkdeveloptool 上传loader到设备
rkdeveloptool ul rkxx_loader_vx.xx.bin
```

其中 `rkxx_loader_vx.xx.bin` 是 Rockchip 针对特定 SoC 发布的官方加载器文件，文件名中的 `xx` 代表 SoC 型号，`vx.xx` 代表版本号。

#### 适用场景

此方法适用于生产环境或需要快速部署的场景，优点是简单可靠，缺点是使用闭源的二进制文件。

### 方法二：从 Rockchip 二进制文件打包

此方法适用于 SD 启动或需要自定义 eMMC 镜像的场景，将 Rockchip 提供的 DDR 初始化文件和 miniloader 组合打包。

#### 操作步骤

```bash
# 使用 mkimage 工具打包 DDR 初始化文件生成 idbloader.img
tools/mkimage -n rkxxxx -T rksd -d rkxx_ddr_vx.xx.bin idbloader.img

# 将 miniloader 追加到 idbloader.img 末尾
cat rkxx_miniloader_vx.xx.bin >> idbloader.img
```

#### 参数说明

- `-n rkxxxx`：指定目标 SoC 型号（如 rk3399、rk3568 等）
- `-T rksd`：指定输出格式为 Rockchip SD 卡镜像
- `-d rkxx_ddr_vx.xx.bin`：指定 DDR 初始化二进制文件作为输入

#### 适用场景

此方法适用于需要创建 SD 启动卡或自定义 eMMC 镜像的场景，提供了适度的灵活性。

### 方法三：从 U-Boot TPL/SPL 打包

此方法提供完全开源的解决方案，适用于需要完全控制引导过程的开发者。

#### 操作步骤

```bash
# 使用 mkimage 工具打包 U-Boot TPL 生成 idbloader.img
tools/mkimage -n rkxxxx -T rksd -d tpl/u-boot-tpl.bin idbloader.img

# 将 U-Boot SPL 追加到 idbloader.img 末尾
cat spl/u-boot-spl.bin >> idbloader.img
```

#### 优势

- 完全开源，代码透明可审计。
- 可以根据需要进行定制修改。
- 与上游 U-Boot 社区保持同步更新。

#### 适用场景

此方法适用于开源社区开发者、需要深度定制引导流程的项目或对软件供应链安全有严格要求的场景。

---

## 烧录与部署

### 烧录位置

无论使用哪种配置方法，生成的 idbloader.img 都需要烧录到存储介质的固定偏移地址：

- **偏移地址**：`0x40`（十六进制）
- **对应扇区**：64（十进制）

### eMMC 烧录

对于 eMMC 存储设备，使用 rkdeveloptool 工具进行烧录：

```bash
# 从本地文件烧录 idbloader.img 到 eMMC 的 0x40 偏移地址
rkdeveloptool wl 0x40 idbloader.img
```

### SD/TF 卡烧录

对于 SD 卡或 TF 卡，使用 dd 命令进行烧录：

```bash
# 将 idbloader.img 写入 SD 卡（假设设备节点为 sdb）
dd if=idbloader.img of=/dev/sdb seek=64

# 验证烧录结果
dd if=/dev/sdb of=backup_idbloader.img skip=64 count=1 bs=512
```

> **注意**：seek 参数的单位是扇区（512 字节），64 扇区正好对应 0x40（64 × 512 = 32768 = 0x8000）的字节偏移量，但 rkdeveloptool 使用的是扇区编号而非字节偏移。

---

## 与其他引导组件的关系

### 组件配合

IDBLoader 本身只是启动链的一部分，需要与其他引导组件配合使用才能完成完整的系统启动过程。根据使用的方案不同，所需的组件也有所差异。

#### 使用 U-Boot SPL 方式

当采用完全开源的 U-Boot 方案时，需要准备以下组件：

| 组件文件 | 描述 | 烧录位置 |
|---------|------|---------|
| idbloader.img | 包含 TPL 和 SPL 的预引导加载程序 | 0x40 |
| u-boot.itb | U-Boot 固件镜像（包含 SPL、设备树和 U-Boot） | 0x4000 |
| boot.img | Linux 内核引导镜像（可选） | 后续扇区 |
| rootfs.img | 根文件系统镜像 | 后续扇区 |

#### 使用 Rockchip miniloader 方式

当采用 Rockchip 官方方案时，需要准备以下组件：

| 组件文件 | 描述 | 烧录位置 |
|---------|------|---------|
| idbloader.img | 包含 DDR 初始化和 miniloader 的预引导加载程序 | 0x40 |
| uboot.img | U-Boot 主引导程序 | 0x4000 |
| trust.img | ARM Trusted Firmware（ATF）可信固件 | 0x6000 |
| boot.img | Linux 内核引导镜像（可选） | 后续扇区 |
| rootfs.img | 根文件系统镜像 | 后续扇区 |

### 启动流程顺序

完整的 Rockchip 设备启动流程如下：

1. **BootRom**：上电后从 ROM 执行，初始化基本硬件，从存储设备加载 IDBLoader。
2. **IDBLoader**：初始化 DDR 内存，加载并跳转到下一阶段引导程序。
3. **U-Boot 或 miniloader**：提供完整的引导功能，包括加载内核、设备树和根文件系统。
4. **Linux 内核**：接管系统控制权，启动用户空间。

---

## 技术特点

### 支持的启动介质

IDBLoader 适用于 Rockchip 平台支持的多种启动介质：

- **eMMC**：嵌入式多媒体卡，是 Rockchip 设备最常用的主存储介质。
- **SD/TF 卡**：用于启动卡制作或可移动存储场景。
- **SPI Flash**：需要特殊配置，通常与其他存储介质配合使用。

### 版本兼容性

- **SoC 型号支持**：支持不同 Rockchip SoC 型号，每个型号有特定的配置文件和打包参数。
- **版本管理**：每个芯片有特定版本号的 DDR 初始化文件和 miniloader，需确保版本匹配。
- **rkbin 兼容性**：与 Rockchip 官方 rkbin 仓库保持兼容，可使用其提供的预编译二进制文件。

---

## 注意事项

### 关键配置要点

1. **偏移地址重要性**：必须烧录到正确的偏移地址（0x40 扇区），错误的偏移地址将导致系统无法启动。
2. **版本匹配**：确保 DDR 初始化文件和 miniloader 版本与目标 SoC 完全匹配，不匹配的版本可能导致 DDR 初始化失败或系统不稳定。
3. **工具版本**：使用的 mkimage 工具版本需要与目标平台匹配，工具版本不匹配可能导致生成的镜像无法正确加载。
4. **启动模式**：某些启动模式（如从 SPI Flash 启动）需要特殊的配置选项（如 SPL_BACK_TO_BROM）。

### 常见问题排查

| 问题现象 | 可能原因 | 解决方案 |
|---------|---------|---------|
| 启动无响应 | IDBLoader 未正确烧录 | 检查烧录偏移地址和文件完整性 |
| DDR 初始化失败 | DDR 初始化文件版本不匹配 | 使用与 SoC 匹配的 DDR 初始化文件 |
| 加载后续阶段失败 | IDBlock 头部损坏 | 重新打包 idbloader.img |
| SD 卡启动失败 | SD 卡格式问题 | 使用 FAT32 格式的 SD 卡 |

---

## 参考资源

- **Rockchip 官方开源仓库**：https://opensource.rock-chips.com/
- **Rockchip rkbin 仓库**：包含各种预编译的加载器二进制文件
- **U-Boot 官方文档**：https://docs.u-boot.org/
- **rkdeveloptool 工具**：用于与 Rockchip 设备进行烧录和调试

---

## 版本历史

| 版本 | 日期 | 更新内容 |
|-----|------|---------|
| 1.0 | 2024-01 | 初始版本，涵盖 IDBLoader 基本概念和配置方法 |

---

*本文档基于 Rockchip 官方开源文档整理，供参考学习使用。*
