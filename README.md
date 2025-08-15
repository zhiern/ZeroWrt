<div align="center">

![GitHub Header](https://git.kejizero.online/zhao/image/raw/branch/main/openwrt.png)

**基于 [OpenWrt](https://github.com/openwrt/openwrt) 打造的高效固件，覆盖 Rockchip、X86_64 平台，专为进阶用户设计！**  

</div>

---

I18N: [English](README_EN.md) | [简体中文](README.md) 

## 🔍 固件信息概览 
- 🛠 **源码基础**：[OpenWrt 官方]
  - Rockchip、X86_64、ARMv8：基于 [OpenWrt 官方](https://github.com/openwrt/openwrt)

- 🔧 **默认设置**：
  - 管理地址：`10.0.0.1`，密码：`password` 或留空
  - 所有 LAN 口均可访问网页终端和 SSH
  - WAN 默认启用防火墙保护
  - Docker 已切换为国内源，支持镜像加速

- 🚀 **增强支持**（x86_64 / Rockchip）：
  - GPU 硬件加速支持
  - BBRv3 拥塞控制
  - Shortcut-FE 支持 UDP 入站
  - NAT6 和全锥型 NAT（NFT / BCM 方案）

- 🎛 **功能优化**：
  - 内置 ZeroWrt 设置菜单，轻松管理
  - 支持高级插件、自定义启动项

---

## 💾 ZeroWrt 固件烧写（SD）

**推荐工具：**<a href="https://www.balena.io/etcher/" target="_blank" ><img style="height:25px;" src="https://git.kejizero.online/zhao/image/raw/branch/main/balenaetcher.svg" /></a>

**SD卡容量：2GB 或更多**

*固件文件无需解压，直接使用工具写入 microSD 卡*

------

## 🛠️ 固件烧写

### 📦 准备工具

- **电脑（Windows），其它操作系统自行搜索相关工具**
- **数据线：USB-A to USB-A 或 Type-C to USB-A**
- **瑞芯微开发工具：**<a href="https://git.kejizero.online/zhao/document/raw/branch/main/RKDevTool_Release_v2.84.zip" target="_blank" >RKDevTool_Release_v2.84.zip</a>

- **Mask 设备驱动：**<a href="https://git.kejizero.online/zhao/document/raw/branch/main/DriverAssitant_v5.1.1.zip" target="_blank" >DriverAssitant_v5.1.1.zip</a>

### 📥 准备固件

- **下载固件文件，并解压出 .img**

### 🚀 操作过程

- **安装 Mask 设备驱动**

- **Mask 模式连接电脑（R5S 断电状态下，取下 SD 卡，使用数据线连接电脑。长按 “Mask” 按钮，接通 R5S 电源直至电脑发现新设备后释放 “Mask” 按钮）**

  <img style="height:100px;" src="https://git.kejizero.online/zhao/image/raw/branch/main/r5s.webp" />



- **打开 瑞芯微开发工具：正常状态：（发现一个Maskrom设备）  缺少驱动：（没有发现设备）**

  **安装步骤：**
  
  **① 点击 “system” 路径选择按钮（选择 zip 解压出来的 IMG 文件）**
  
  <img src="date/select_firmware.png" />
  
  
  
  **② 点击 “执行”（固件写入完成后会自动重启进入 OpenWrt 系统）**
  
  
  
- ***注意：通过电脑烧写固件请使用本站下载的 [瑞芯微开发工具](https://git.kejizero.online/zhao/document/raw/branch/main/RKDevTool_Release_v2.84.zip)。***

------

## 📤 固件烧写（SD to eMMC）

```shell
# 1、下载最新 Releases 固件并通过 SD 卡启动
# 2、使用 Xftp 等工具上传一份固件到 /tmp 目录，或通过终端 wget 在线下载固件到 /tmp 目录

# 3、使用内建命令写入固件到 eMMC 存储（请根据实际文件名称与路径）

emmc-install /tmp/xx-squashfs-sysupgrade.img.gz

```

**固件写入完成后，取下 SD 卡，手动断电重启即可完成。**

------

## 📂 固件展示 / 预览截图

<div align="center">

![示例图 1](https://git.kejizero.online/zhao/image/raw/branch/main/0001.png)  
![示例图 2](https://git.kejizero.online/zhao/image/raw/branch/main/0002.png)  
![示例图 3](https://git.kejizero.online/zhao/image/raw/branch/main/0003.png)  
![示例图 4](https://git.kejizero.online/zhao/image/raw/branch/main/0004.png)

</div>

---

## 💬 交流群与支持

如有技术问题或想交流使用经验，可加入我们的讨论群：

- 🧧 QQ 交流群：579896728 👉 [点击加入](https://qm.qq.com/q/oe4EAtvPIO)
- 🌐 Telegram 群组 👉 [点击加入](https://t.me/kejizero)

---

## 💰 打赏支持

感谢你的支持，我们会将每一笔打赏用于改善服务与开发。**打赏 20 元以上可获取 VIP 区域访问权限！**

👉 [点击打赏](https://pay.kejizero.online)

---

## 🏆 鸣谢 [![](https://img.shields.io/badge/-跪谢各大佬-FFFFFF.svg)](#鸣谢-)
| [ImmortalWrt](https://github.com/immortalwrt) | [coolsnowwolf](https://github.com/coolsnowwolf) | [P3TERX](https://github.com/P3TERX) | [Flippy](https://github.com/unifreq) |
| :-------------: | :-------------: | :-------------: | :-------------: |
| <img width="100" src="https://avatars.githubusercontent.com/u/53193414"/> | <img width="100" src="https://avatars.githubusercontent.com/u/31687149"/> | <img width="100" src="https://avatars.githubusercontent.com/u/25927179"/> | <img width="100" src="https://avatars.githubusercontent.com/u/39355261"/> |
| [sbwml](https://github.com/sbwml) | [SuLingGG](https://github.com/SuLingGG) | [QiuSimons](https://github.com/QiuSimons) | [padavanonly](https://github.com/padavanonly/immortalwrt-mt798x-24.10) |
| <img width="100" src="https://avatars.githubusercontent.com/u/16485166?v=4"/> | <img width="100" src="https://avatars.githubusercontent.com/u/22287562"/> | <img width="100" src="https://avatars.githubusercontent.com/u/45143996"/> | <img width="100" src="https://avatars.githubusercontent.com/u/83120842?v=4"/> |

---

## ⚠️ 免责声明

> - 本固件仅供学习研究，请勿用于商业用途  
> - 使用本固件所带来的一切后果由使用者自行承担  
> - 不保证完全无 bug，开发者不提供定制支持  
> - 请遵守国家网络安全相关法律法规  
