#!/bin/bash -e

# =====================
# 初始化设置
# =====================
# 语言选择
LANG_CHOICE=""
AGREED="no"

# 颜色定义
RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[1;33m'
BLUE_COLOR='\033[0;34m'
CYAN_COLOR='\033[0;36m'
RES='\033[0m'

# =====================
# 函数定义
# =====================

# 彩色输出函数
color_output() {
    echo -e "$1"
}

# 显示语言选择菜单
select_language() {
    clear
    color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    color_output "\e[36m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\e[0m"
    color_output "\e[36m┃                                       ┃\e[0m"
    color_output "\e[36m┃        \e[33m请选择语言/Select Language\e[36m     ┃\e[0m"
    color_output "\e[36m┃                                       ┃\e[0m"
    color_output "\e[36m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\e[0m"
    color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    color_output ""
    color_output "1. 中文"
    color_output "2. English"
    color_output "0. 退出/Exit"  
    color_output ""
    color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    
    while [[ -z "$LANG_CHOICE" ]]; do
        read -p "$(color_output "\e[33m请选择语言 [0-2]: \e[0m")" LANG_CHOICE
        case "$LANG_CHOICE" in
            1) LANG_CHOICE="zh";;
            2) LANG_CHOICE="en";;
            0) exit 0 ;;
            *) 
                color_output "\e[31m无效选择，请重新输入\e[0m"
                LANG_CHOICE=""
                ;;
        esac
    done
}

# 显示用户协议
show_agreement() {
    clear
    if [[ "$LANG_CHOICE" == "zh" ]]; then
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        color_output "\e[36m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\e[0m"
        color_output "\e[36m┃  \e[33mOpenWrt 自动化构建工具用户协议\e[36m       ┃\e[0m"
        color_output "\e[36m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\e[0m"
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        color_output ""
        color_output "1. 本工具仅用于学习和研究目的，不得用于非法用途。"
        color_output "2. 使用本工具构建 OpenWrt 可能需要较长时间和大量资源。"
        color_output "3. 作者不对使用本工具造成的任何损失负责。"
        color_output "4. 继续使用表示您同意以上条款。"
        color_output ""
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        
        while [[ "$AGREED" != "yes" ]]; do
            read -p "$(color_output "\e[33m您是否同意上述条款？(yes/no): \e[0m")" AGREED
            case "$AGREED" in
                yes|YES|y|Y) 
                    AGREED="yes"
                    ;;
                no|NO|n|N)
                    color_output "\e[31m您必须同意条款才能使用本工具。\e[0m"
                    exit 1
                    ;;
                *)
                    color_output "\e[31m请输入yes或no\e[0m"
                    ;;
            esac
        done
    else
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        color_output "\e[36m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\e[0m"
        color_output "\e[36m┃   \e[33mOpenWrt Automated Build Tool User Agreement\e[36m   ┃\e[0m"
        color_output "\e[36m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\e[0m"
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        color_output ""
        color_output "1. This tool is for learning and research only, not for illegal use."
        color_output "2. Building OpenWrt with this tool may take a long time and resources."
        color_output "3. The author is not responsible for any damage caused by this tool."
        color_output "4. Continuing to use means you agree to these terms."
        color_output ""
        color_output "\e[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
        
        while [[ "$AGREED" != "yes" ]]; do
            read -p "$(color_output "\e[33mDo you agree to these terms? (yes/no): \e[0m")" AGREED
            case "$AGREED" in
                yes|YES|y|Y) 
                    AGREED="yes"
                    ;;
                no|NO|n|N)
                    color_output "\e[31mYou must agree to the terms to use this tool.\e[0m"
                    exit 1
                    ;;
                *)
                    color_output "\e[31mPlease enter yes or no\e[0m"
                    ;;
            esac
        done
    fi
}

# 选择设备类型
select_device_type() {
    clear
    # 获取系统信息
    OS_INFO=$( (lsb_release -ds || cat /etc/*release 2>/dev/null | head -n1 || uname -om) 2>/dev/null | tr -d '"')
    CPU_CORES=$(nproc)
    MEM_TOTAL=$(awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "Unknown")
    CURRENT_ARCH=$(uname -m)
    HOSTNAME=$(hostname)

    # 统一框线宽度为58个字符
    BOX_WIDTH=58

    if [[ "$LANG_CHOICE" == "zh" ]]; then
        # 中文界面
        color_output "\e[36m╔══════════════════════════════════════════════════════════╗\e[0m"
        color_output "\e[36m║                   \e[33mZeroWrt 编译设备选择\e[36m                   ║\e[0m"
        color_output "\e[36m╚══════════════════════════════════════════════════════════╝\e[0m"
        echo

        # 系统信息框
        color_output "\e[36m┌────────────────────── \e[34m系统信息\e[36m ────────────────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  主机名称 : \e[32m$(printf "%-40s" "$HOSTNAME")\e[36m   │\e[0m"
        color_output "\e[36m│  系统版本 : \e[32m$(printf "%-40s" "$OS_INFO")\e[36m   │\e[0m"
        color_output "\e[36m│  CPU架构  : \e[32m$(printf "%-40s" "$CURRENT_ARCH")\e[36m   │\e[0m"
        color_output "\e[36m│  CPU核心  : \e[32m$(printf "%-40s" "$CPU_CORES")\e[36m   │\e[0m"
        color_output "\e[36m│  总内存   : \e[32m$(printf "%-40s" "${MEM_TOTAL}GB")\e[36m   │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        # 设备选择框
        color_output "\e[36m┌───────────────── \e[34m请选择目标设备类型\e[36m ───────────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[33m1.\e[0m x86_64 (64位PC/服务器)                         \e[36m    │\e[0m"
        color_output "\e[36m│  \e[33m2.\e[0m Rockchip (ARM开发板 - 如RK3568/RK3588)         \e[36m    │\e[0m"
        color_output "\e[36m│  \e[33m3.\e[0m Mediatek (联发科 - 如MT7981/MT7986)         \e[36m       │\e[0m"
        color_output "\e[36m│  \e[33m0.\e[0m 退出                                           \e[36m    │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        # 相关信息框
        color_output "\e[36m┌────────────────────── \e[34m相关信息\e[36m ────────────────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[32m说明     : 此工具用于自动化编译 ZeroWrt\e[36m               │\e[0m"
        color_output "\e[36m│  \e[32m博客地址 : https://www.kejizero.online\e[36m                │\e[0m"
        color_output "\e[36m│  \e[32m固件下载 : http://openwrt.kejizero.online\e[36m             │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        while [[ -z "$type" ]]; do
            read -p "$(color_output "\e[33m请输入选择 [0-3]: \e[0m")" device_choice
            case "$device_choice" in
                1)
                    type="x86_64"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ 已选择: x86_64 设备 (64位PC/服务器)\e[36m                 │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                2)
                    type="rockchip"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ 已选择: Rockchip ARM开发板\e[36m                          │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            	3)
                	while [[ -z "$mtk_subtype" ]]; do
                    	color_output "\e[36m┌─────────────────────── \e[34m联发科设备选择\e[36m ─────────────────────┐\e[0m"
                    	color_output "\e[36m│                                                            │\e[0m"
                    	color_output "\e[36m│  \e[33m1.\e[0m MT7981 (如 Redmi AX6000、小米 AX3000T 等)           \e[36m   │\e[0m"
                    	color_output "\e[36m│  \e[33m2.\e[0m MT7986 (如 Belkin RT3200、小米 AX9000 等)           \e[36m   │\e[0m"
                    	color_output "\e[36m│                                                            │\e[0m"
                    	color_output "\e[36m└────────────────────────────────────────────────────────────┘\e[0m"
                    	read -p "$(color_output "\e[33m请选择芯片型号 [1-2]: \e[0m")" mtk_choice
                    	case "$mtk_choice" in
                        	1)
                            	type="mediatek_mt7981"
                            	mtk_subtype="MT7981"
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[32m✓ 已选择: 联发科 MT7981 芯片设备\e[36m                      │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                        	2)
                            	type="mediatek_mt7986"
                            	mtk_subtype="MT7986"
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[32m✓ 已选择: 联发科 MT7986 芯片设备\e[36m                      │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                        	*)
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[31m✗ 无效输入，请重新选择。\e[36m                              │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                    	esac
                	done
                	;;
                0)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ 感谢使用，再见！\e[36m                                    │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    exit 0
                    ;;
                *)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[31m✗ 无效输入，请重新选择。\e[36m                              │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            esac
        done

    else
        # 英文界面
        color_output "\e[36m╔══════════════════════════════════════════════════════════╗\e[0m"
        color_output "\e[36m║              \e[33mZeroWrt Build Target Selection\e[36m              ║\e[0m"
        color_output "\e[36m╚══════════════════════════════════════════════════════════╝\e[0m"
        echo

        # System Information
        color_output "\e[36m┌──────────────────── \e[34mSystem Information\e[36m ────────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  Hostname   : \e[32m$(printf "%-40s" "$HOSTNAME")\e[36m │\e[0m"
        color_output "\e[36m│  OS Version : \e[32m$(printf "%-40s" "$OS_INFO")\e[36m │\e[0m"
        color_output "\e[36m│  CPU Arch   : \e[32m$(printf "%-40s" "$CURRENT_ARCH")\e[36m │\e[0m"
        color_output "\e[36m│  CPU Cores  : \e[32m$(printf "%-40s" "$CPU_CORES")\e[36m │\e[0m"
        color_output "\e[36m│  Memory     : \e[32m$(printf "%-40s" "${MEM_TOTAL}GB")\e[36m │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        # Device Selection
        color_output "\e[36m┌─────────────── \e[34mSelect Target Device Type\e[36m ──────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[33m1.\e[0m x86_64 (64-bit PC/Server)                          \e[36m│\e[0m"
        color_output "\e[36m│  \e[33m2.\e[0m Rockchip (ARM Board - e.g. RK3568/RK3588)          \e[36m│\e[0m"
        color_output "\e[36m│  \e[33m3.\e[0m Mediatek (MediaTek - e.g. MT7981/MT7986)         \e[36m  │\e[0m"
        color_output "\e[36m│  \e[33m0.\e[0m Exit                                              \e[36m │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        # Related Information
        color_output "\e[36m┌────────────────── \e[34mRelated Information\e[36m ─────────────────┐\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[32mDescription : Tool for building ZeroWrt\e[36m               │\e[0m"
        color_output "\e[36m│  \e[32mBlog       : https://www.kejizero.online\e[36m              │\e[0m"
        color_output "\e[36m│  \e[32mFirmware   : http://openwrt.kejizero.online\e[36m           │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        echo

        while [[ -z "$type" ]]; do
            read -p "$(color_output "\e[33mEnter your choice [0-3]: \e[0m")" device_choice
            case "$device_choice" in
                1)
                    type="x86_64"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ Selected: x86_64 (64-bit PC/Server)\e[36m                 │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                2)
                    type="rockchip"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ Selected: Rockchip ARM Board\e[36m                        │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            	3)
                	while [[ -z "$mtk_subtype" ]]; do
                    	color_output "\e[36m┌────────────────── \e[34mMediaTek Device Selection\e[36m ───────────────┐\e[0m"
                    	color_output "\e[36m│                                                            │\e[0m"
                    	color_output "\e[36m│  \e[33m1.\e[0m MT7981 (Such as Redmi AX6000, Xiaomi AX3000T, etc.)    \e[36m│\e[0m"
                    	color_output "\e[36m│  \e[33m2.\e[0m MT7986 (Such as Belkin RT3200, Xiaomi AX9000, etc.)    \e[36m│\e[0m"
                    	color_output "\e[36m│                                                            │\e[0m"
                    	color_output "\e[36m└────────────────────────────────────────────────────────────┘\e[0m"
                    	read -p "$(color_output "\e[33mPlease select chip model [1-2]: \e[0m")" mtk_choice
                    	case "$mtk_choice" in
                        	1)
                            	type="mediatek_mt7981"
                            	mtk_subtype="MT7981"
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[32m✓ Selected: MediaTek MT7981 chip device\e[36m                      │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                        	2)
                            	type="mediatek_mt7986"
                            	mtk_subtype="MT7986"
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[32m✓ Selected: MediaTek MT7986 chip device\e[36m                      │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                        	*)
                            	color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                            	color_output "\e[36m│  \e[31m✗ Invalid input, please try again.\e[36m                              │\e[0m"
                            	color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                            	;;
                    	esac
                	done
                	;;
                0)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ Thank you for using this tool. Goodbye!\e[36m             │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    exit 0
                    ;;
                *)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[31m✗ Invalid input. Please try again.\e[36m                    │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            esac
        done
    fi
}

# 询问是否使用Toolchain缓存
ask_toolchain_cache() {
    clear
    if [[ "$LANG_CHOICE" == "zh" ]]; then
        color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
        color_output "\e[36m│              \e[33mToolchain 缓存加速选项\e[36m                    │\e[0m"
        color_output "\e[36m├────────────────────────────────────────────────────────┤\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  使用预编译的 Toolchain 可以显著加快编译速度           │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[33m1.\e[0m 使用 Toolchain 缓存 (加速编译)                 \e[36m    │\e[0m"
        color_output "\e[36m│  \e[33m2.\e[0m 不使用 (从头开始编译)                          \e[36m    │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        
        while [[ -z "$BUILD_FAST" ]]; do
            read -p "$(color_output "\e[33m请选择 [1-2]: \e[0m")" cache_choice
            case "$cache_choice" in
                1)
                    BUILD_FAST="y"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ 已启用: 将使用 Toolchain 缓存加速编译\e[36m               │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                2)
                    BUILD_FAST="n"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ 已禁用: 将从头开始编译\e[36m                              │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                *)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[31m✗ 无效输入，请重新选择\e[36m                                │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            esac
        done
    else
        color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
        color_output "\e[36m│             \e[33mToolchain Cache Option\e[36m                     │\e[0m"
        color_output "\e[36m├────────────────────────────────────────────────────────┤\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  Using precompiled Toolchain can significantly speed   │\e[0m"
        color_output "\e[36m│  up compilation 					 │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m│  \e[33m1.\e[0m Use Toolchain cache (faster build)              \e[36m   │\e[0m"
        color_output "\e[36m│  \e[33m2.\e[0m Don't use (compile from scratch)                 \e[36m  │\e[0m"
        color_output "\e[36m│                                                        │\e[0m"
        color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
        
        while [[ -z "$BUILD_FAST" ]]; do
            read -p "$(color_output "\e[33mYour choice [1-2]: \e[0m")" cache_choice
            case "$cache_choice" in
                1)
                    BUILD_FAST="y"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ Enabled: Will use Toolchain cache\e[36m                   │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                2)
                    BUILD_FAST="n"
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[32m✓ Disabled: Will compile from scratch\e[36m                 │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
                *)
                    color_output "\e[36m┌────────────────────────────────────────────────────────┐\e[0m"
                    color_output "\e[36m│  \e[31m✗ Invalid input, please try again\e[36m                     │\e[0m"
                    color_output "\e[36m└────────────────────────────────────────────────────────┘\e[0m"
                    ;;
            esac
        done
    fi
    sleep 1
}

# =====================
# 配置参数
# =====================
# 脚本URL
export mirror=https://script.kejizero.online

# 私有Gitea
export gitea=https://git.kejizero.online

# GitHub镜像
export github="github.com"

# 源码分支
export branch=v24.10.1

# curl
CURL_BAR="--progress-bar"

# =====================
# 主程序
# =====================

# 选择语言并显示协议
select_language
show_agreement
select_device_type
ask_toolchain_cache

# 检查root权限
if [ "$(id -u)" = "0" ]; then
    color_output "${RED_COLOR}[ERROR] 不支持使用root用户构建${RES}"
    exit 1
fi

# 显示构建信息
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${CYAN_COLOR}[INFO] 开始OpenWrt自动化构建${RES}"
    color_output "${YELLOW_COLOR}构建类型: ${type:-未指定}${RES}"
    color_output "${YELLOW_COLOR}CPU核心数: $(nproc --all)${RES}"
else
    color_output "${CYAN_COLOR}[INFO] Starting OpenWrt automated build${RES}"
    color_output "${YELLOW_COLOR}Build type: ${type:-Not specified}${RES}"
    color_output "${YELLOW_COLOR}CPU cores: $(nproc --all)${RES}"
fi

# 克隆仓库
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 克隆仓库...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Cloning repository...${RES}"
fi
# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
  # 参数1是仓库地址，参数2是分支名，参数3是目标目录
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # 克隆仓库到目标目录，并指定分支名和深度为1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}
# 定义一些变量，存储仓库地址和分支名
openwrt_release="$(curl -s https://github.com/openwrt/openwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
immortalwrt_release="$(curl -s https://github.com/immortalwrt/immortalwrt/tags | grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" | sed -n '/[2-9][4-9]/p' | sed -n 1p | sed 's/.tar.gz//g')"
openwrt_repo="https://github.com/openwrt/openwrt.git"
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
mediatek_repo="https://github.com/padavanonly/immortalwrt-mt798x-24.10"


# 开始克隆仓库，并行执行
if [[ "$type" == "rockchip" || "$type" == "x86_64" ]]; then
    clone_repo $openwrt_repo $openwrt_release openwrt &
    clone_repo $immortalwrt_repo $immortalwrt_release immortalwrt &
    clone_repo $openwrt_repo openwrt-24.10 openwrt_snap &
elif [[ "$type" == "mediatek_mt7981" || "$type" == "mediatek_mt7986" ]]; then
    clone_repo $mediatek_repo 2410 openwrt_mediatek &
fi
wait


# 进行一些处理
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 进行一些处理...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Do some processing...${RES}"
fi
if [[ "$type" == "rockchip" || "$type" == "x86_64" ]]; then
    find openwrt/package/* -maxdepth 0 ! -name 'firmware' ! -name 'kernel' ! -name 'base-files' ! -name 'Makefile' -exec rm -rf {} +
    rm -rf ./openwrt_snap/package/firmware ./openwrt_snap/package/kernel ./openwrt_snap/package/base-files ./openwrt_snap/package/Makefile
    cp -rf ./openwrt_snap/package/* ./openwrt/package/
    cp -rf ./openwrt_snap/feeds.conf.default ./openwrt/feeds.conf.default
fi

# 进入目录
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 进入OpenWrt目录...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Entering OpenWrt directory...${RES}"
fi
if [[ "$type" == "rockchip" || "$type" == "x86_64" ]]; then
    cd openwrt
elif [[ "$type" == "mediatek_mt7981" || "$type" == "mediatek_mt7986" ]]; then
    cd openwrt_mediatek
fi

# 初始化feeds
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 初始化feeds...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Initializing feeds...${RES}"
fi
./scripts/feeds update -a
./scripts/feeds install -a

# 下载准备脚本
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 下载准备脚本...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Downloading preparation scripts...${RES}"
fi
if [[ "$type" == "x86_64" || "$type" == "rockchip" ]]; then
    # 下载准备脚本
    clear
    curl -sO $mirror/openwrt/scripts/00-prepare_base.sh
    curl -sO $mirror/openwrt/scripts/01-prepare_package.sh
    curl -sO $mirror/openwrt/scripts/03-convert_translation.sh
    if [ "$type" = "x86_64" ]; then
        curl -sO $mirror/openwrt/scripts/x86_64/02-custom_settings_x86.sh
    elif [ "$type" = "rockchip" ]; then
        curl -sO $mirror/openwrt/scripts/rockchip/02-custom_settings_rk.sh
    fi
elif [[ "$type" == "mediatek_mt7981" || "$type" == "mediatek_mt7986" ]]; then
    curl -sO $mirror/openwrt/scripts/mediatek/00-custom_settings_mediatek.sh
fi
chmod 0755 *sh

# 执行准备脚本
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 执行准备脚本...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Executing preparation scripts...${RES}"
fi

if [[ "$type" == "x86_64" || "$type" == "rockchip" ]]; then
    bash 00-prepare_base.sh
    bash 01-prepare_package.sh
    if [ "$type" = "x86_64" ]; then
        bash 02-custom_settings_x86.sh
    elif [ "$type" = "rockchip" ]; then
        bash 02-custom_settings_rk.sh
    fi
    bash 03-convert_translation.sh
elif [[ "$type" == "mediatek_mt7981" || "$type" == "mediatek_mt7986" ]]; then
    bash 00-custom_settings_mediatek.sh
fi

# 清理脚本文件
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 清理脚本文件...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Cleaning up script files...${RES}"
fi
rm -rf *.sh   

# 加载设备配置
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${YELLOW_COLOR}[STEP] 加载设备配置...${RES}"
else
    color_output "${YELLOW_COLOR}[STEP] Loading device configuration...${RES}"
fi

if [[ "$type" == "x86_64" ]]; then
    curl -s "$mirror/openwrt/scripts/x86_64/24-config-musl-x86" > .config
elif [[ "$type" == "rockchip" ]]; then
    curl -s "$mirror/openwrt/scripts/rockchip/24-config-musl-rockchip" > .config
elif [[ "$type" == "mediatek_mt7981" ]]; then
    curl -s "$mirror/openwrt/scripts/mediatek/24-config-musl-mediatek-mt7981" > .config
elif [[ "$type" == "mediatek_mt7986" ]]; then
    curl -s "$mirror/openwrt/scripts/mediatek/24-config-musl-mediatek-mt7986" > .config
fi


# Toolchain Cache
TOOLCHAIN_URL=https://github.com/oppen321/openwrt_caches/releases/download/OpenWrt_Toolchain_Cache
if [ "$BUILD_FAST" = "y" ]; then
    if [ "$type" = "rockchip" ] || [ "$type" = "x86_64" ]; then
        echo -e "\n${GREEN_COLOR}Download Toolchain GCC13...${RES}"
        curl -L -k ${TOOLCHAIN_URL}/toolchain_gcc13_${type}.tar.zst -o toolchain.tar.zst $CURL_BAR
    elif [[ "$type" == "mediatek_mt7981" || "$type" == "mediatek_mt7986" ]]; then
        echo -e "\n${GREEN_COLOR}Download Toolchain GCC13...${RES}"
        curl -L -k ${TOOLCHAIN_URL}/toolchain_gcc13_mediatek.tar.zst -o toolchain.tar.zst $CURL_BAR
    fi
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -I "zstd" -xf toolchain.tar.zst
    rm -f toolchain.tar.zst
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# init openwrt config
rm -rf tmp/*

# 生成 .config
make defconfig

# 下载 DL库
clear
color_output "${GREEN_COLOR}[INFO] 下载 DL库...${RES}"
make download -j8

# 编译过程
clear
if [[ "$LANG_CHOICE" == "zh" ]]; then
    color_output "${GREEN_COLOR}[INFO] 开始编译固件...${RES}"
else
    color_output "${GREEN_COLOR}[INFO] Starting firmware compilation...${RES}"
fi
IGNORE_ERRORS=1 make -j$(($(nproc) + 1))

# 完成提示
if [[ $? -eq 0 ]]; then
    if [[ "$LANG_CHOICE" == "zh" ]]; then
        color_output "\n${GREEN_COLOR}[SUCCESS] 构建过程已完成！${RES}"
    else
        color_output "\n${GREEN_COLOR}[SUCCESS] Build process completed!${RES}"
    fi
else
    if [[ "$LANG_CHOICE" == "zh" ]]; then
        color_output "\n${RED_COLOR}[FAIL] 构建失败，请执行 make V=s -j1 检查错误信息！${RES}"
    else
        color_output "\n${RED_COLOR}[FAIL] Build failed, please check the error log!${RES}"
    fi
fi