#!/bin/bash -e
RED_COLOR='\033[1;31m'
GREEN_COLOR='\033[1;32m'
YELLOW_COLOR='\033[1;33m'
BLUE_COLOR='\033[1;34m'
PINK_COLOR='\033[1;35m'
SHAN='\033[1;33;5m'
RES='\033[0m'

GROUP=
group() {
    endgroup
    echo "::group::  $1"
    GROUP=1
}
endgroup() {
    if [ -n "$GROUP" ]; then
        echo "::endgroup::"
    fi
    GROUP=
}

echo -e ""
echo -e "${BLUE_COLOR}╔════════════════════════════════════════════════════════════╗${RES}"
echo -e "${BLUE_COLOR}║${RES}                     OPENWRT BUILD SYSTEM                   ${BLUE_COLOR}║${RES}"
echo -e "${BLUE_COLOR}╚════════════════════════════════════════════════════════════╝${RES}"
echo -e "${BLUE_COLOR}┌────────────────────────────────────────────────────────────┐${RES}"
echo -e "${BLUE_COLOR}│${RES}  🛠️  ${YELLOW_COLOR}Developer:${RES} OPPEN321                                  ${BLUE_COLOR}│${RES}"
echo -e "${BLUE_COLOR}│${RES}  🌐  ${YELLOW_COLOR}Blog:${RES} www.kejizero.online                            ${BLUE_COLOR}│${RES}"
echo -e "${BLUE_COLOR}│${RES}  💡  ${YELLOW_COLOR}Philosophy:${RES} Open Source · Customization · Performance${BLUE_COLOR}│${RES}"
echo -e "${BLUE_COLOR}└────────────────────────────────────────────────────────────┘${RES}"
echo -e "${BLUE_COLOR}🔧 ${GREEN_COLOR}Building:${RES} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BLUE_COLOR}══════════════════════════════════════════════════════════════${RES}"
echo -e ""

# 自定义链接地址
export mirror=http://127.0.0.1:8080
export gitea="git.kejizero.online"
export github="github.com"

# 检测 Root
if [ "$(id -u)" = "0" ]; then
    export FORCE_UNSAFE_CONFIGURE=1 FORCE=1
fi

# 开始时间
starttime=`date +'%Y-%m-%d %H:%M:%S'`
CURRENT_DATE=$(date +%s)

# 处理器核心数设置
cores=`expr $(nproc --all) + 1`

# 进度条设置
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

SUPPORTED_BOARDS="rockchip x86_64"
if [ -z "$1" ] || ! echo "$SUPPORTED_BOARDS" | grep -qw "$2"; then
    echo -e "\n${RED_COLOR}Building type not specified or unsupported board: '$2'.${RES}\n"
    echo -e "Usage:\n"

    for board in $SUPPORTED_BOARDS; do
        echo -e "$board releases: ${GREEN_COLOR}bash build.sh v24 $board${RES}"
    done
    echo
    exit 1
fi

# 源分支
latest_release="v$(curl -s $mirror/tags/v24)"
export branch=openwrt-24.10
export version=v24

# LAN
[ -n "$LAN" ] && export LAN=$LAN || export LAN=10.0.0.1

# 设备类型
case "$2" in
    rockchip)
        platform="rockchip"
        toolchain_arch="aarch64_generic"
        ;;
    x86_64)
        platform="x86_64"
        toolchain_arch="x86_64"
        ;;
esac
export platform toolchain_arch

# GCC 版本设置
case "$GCC_VERSION" in
  GCC13)
    export gcc_version=13
    ;;
  GCC14)
    export gcc_version=14
    ;;
  GCC15)
    export gcc_version=15
    ;;
esac

echo "👉 已选择 GCC 版本: $gcc_version"


# 脚本定义
export \
    ENABLE_BPF=$ENABLE_BPF \
    ROOT_PASSWORD=$ROOT_PASSWORD

# 打印设备信息
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
case "$platform" in
    x86_64)
        echo -e "${GREEN_COLOR}Model: x86_64${RES}"
        ;;
    rockchip)
        echo -e "${GREEN_COLOR}Model: rockchip${RES}"
        ;;
esac

# 打印构建选项
get_kernel_version=$(curl -s $mirror/tags/kernel-6.6)
kmod_hash=$(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}' | tail -1 | md5sum | awk '{print $1}')
kmodpkg_name=$(echo $(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}')~$(echo $kmod_hash)-r1)
echo -e "${GREEN_COLOR}Kernel: $kmodpkg_name ${RES}"
echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"
echo -e "${GREEN_COLOR}SCRIPT_URL:${RES} ${BLUE_COLOR}$mirror${RES}\r\n"
echo -e "${GREEN_COLOR}GCC VERSION: $gcc_version${RES}"
print_status() {
    local name="$1"
    local value="$2"
    local true_color="${3:-$GREEN_COLOR}"
    local false_color="${4:-$YELLOW_COLOR}"
    local newline="${5:-}"
    if [ "$value" = "y" ]; then
        echo -e "${GREEN_COLOR}${name}:${RES} ${true_color}true${RES}${newline}"
    else
        echo -e "${GREEN_COLOR}${name}:${RES} ${false_color}false${RES}${newline}"
    fi
}
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN:${RES} $LAN" || echo -e "${GREEN_COLOR}LAN:${RES} 10.0.0.1"
[ -n "$ROOT_PASSWORD" ] \
    && echo -e "${GREEN_COLOR}Default Password:${RES} ${BLUE_COLOR}$ROOT_PASSWORD${RES}" \
    || echo -e "${GREEN_COLOR}Default Password:${RES} (${YELLOW_COLOR}No password${RES})"
echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}musl${RES}"
echo -e "${GREEN_COLOR}Web Server:${RES} ${BLUE_COLOR}$web_server${RES}"
print_status "ENABLE_OTA"        "$ENABLE_OTA"
print_status "ENABLE_BPF"        "$ENABLE_BPF" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LTO"        "$ENABLE_LTO" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LOCAL_KMOD" "$ENABLE_LOCAL_KMOD"
print_status "BUILD_FAST"        "$BUILD_FAST" "$GREEN_COLOR" "$YELLOW_COLOR" "\n"

# 清理旧的文件
rm -rf openwrt immortalwrt

# openwrt - 克隆
[ "$(whoami)" = "runner" ] && group "source code"
git clone --depth=1 https://$github/openwrt/openwrt -b $branch
git clone --depth=1 https://$github/immortalwrt/immortalwrt -b $branch

if [ -d openwrt ]; then
    cd openwrt
    curl -Os $mirror/openwrt/patch/key.tar.gz && tar zxf key.tar.gz && rm -f key.tar.gz
else
    echo -e "${RED_COLOR}Failed to download source code${RES}"
    exit 1
fi

# 版本设置
git describe --abbrev=0 --tags > version.txt

# 替换更新源
curl -s $mirror/openwrt/doc/feeds/feeds.conf.default > feeds.conf.default

# 更新并安装源
[ "$(whoami)" = "runner" ] && group "feeds update -a"
./scripts/feeds update -a
[ "$(whoami)" = "runner" ] && endgroup

[ "$(whoami)" = "runner" ] && group "feeds install -a"
./scripts/feeds install -a
[ "$(whoami)" = "runner" ] && endgroup

# 加载程序
if [ -f ../dl.gz ]; then
    tar xf ../dl.gz -C .
fi

###############################################
echo -e "\n${GREEN_COLOR}Patching ...${RES}\n"

# scripts
scripts=(
  00-prepare_base.sh
  01-prepare_package.sh
  02-prepare_adguard_core.sh
  03-preset_mihimo_core.sh
  04-convert_translation.sh
  06-fix-source.sh
  10-custom.sh
  99_clean_build_cache.sh
)
for script in "${scripts[@]}"; do
  curl -sO "$mirror/openwrt/scripts/$script"
done
if [ "$platform" = "rockchip" ]; then
    curl -sO "$mirror/openwrt/scripts/05-rockchip_target_only.sh"
    export core=arm64
    export opkg=aarch64_generic
elif [ "$platform" = "x86_64" ]; then
    curl -sO "$mirror/openwrt/scripts/05-x86_64_target_only.sh"
    export core=amd64
    export opkg=x86_64
fi
chmod 0755 *sh
[ "$(whoami)" = "runner" ] && group "patching openwrt"
bash 00-prepare_base.sh
bash 01-prepare_package.sh
bash 02-prepare_adguard_core.sh
bash 03-preset_mihimo_core.sh
#bash 04-convert_translation.sh
bash 06-fix-source.sh
if [ "$platform" = "rockchip" ]; then
    bash 05-rockchip_target_only.sh
elif [ "$platform" = "x86_64" ]; then
    bash 05-x86_64_target_only.sh
fi
[ -f "10-custom.sh" ] && bash 10-custom.sh
find feeds -type f -name "*.orig" -exec rm -f {} \;
[ "$(whoami)" = "runner" ] && endgroup

rm -f 0*-*.sh 10-custom.sh
rm -rf ../master

# Load devices Config
if [ "$platform" = "x86_64" ]; then
    curl -s $mirror/openwrt/24-config-musl-x86 > .config
elif [ "$platform" = "rockchip" ]; then
    curl -s $mirror/openwrt/24-config-musl-rockchip > .config
fi

# config-common
curl -s $mirror/openwrt/24-config-common >> .config

# ota
[ "$ENABLE_OTA" = "y" ] && [ "$version" = "v24" ] && echo 'CONFIG_PACKAGE_luci-app-ota=y' >> .config

# docker
[ "$ENABLE_DOCKER" = "y" ] && curl -s $mirror/openwrt/generic/config-docker >> .config

# bpf
[ "$ENABLE_BPF" = "y" ] && curl -s $mirror/openwrt/generic/config-bpf >> .config

# LTO
export ENABLE_LTO=$ENABLE_LTO
[ "$ENABLE_LTO" = "y" ] && curl -s $mirror/openwrt/generic/config-lto >> .config

# not all kmod
[ "$NO_KMOD" = "y" ] && sed -i '/CONFIG_ALL_KMODS=y/d' .config

# uhttpd
[ "$web_server" = "uhttpd" ] && sed -i '/nginx/d' .config && echo 'CONFIG_PACKAGE_ariang=y' >> .config

# local kmod
if [ "$ENABLE_LOCAL_KMOD" = "y" ]; then
    echo -e "\n# local kmod" >> .config
    echo "CONFIG_TARGET_ROOTFS_LOCAL_PACKAGES=y" >> .config
fi

# gcc15 patches
[ "$(whoami)" = "runner" ] && group "patching toolchain"
curl -s $mirror/openwrt/patch/gcc/200-toolchain-gcc-add-support-for-GCC-15.patch | patch -p1

# gcc config
echo -e "\n# gcc ${gcc_version}" >> .config
echo -e "CONFIG_DEVEL=y" >> .config
echo -e "CONFIG_TOOLCHAINOPTS=y" >> .config
echo -e "CONFIG_GCC_USE_VERSION_${gcc_version}=y\n" >> .config
[ "$(whoami)" = "runner" ] && endgroup

# Toolchain Cache
if [ "$BUILD_FAST" = "y" ]; then
    echo -e "\n${GREEN_COLOR}Download Toolchain ...${RES}"
    [ -f /etc/os-release ] && source /etc/os-release
    TOOLCHAIN_URL=https://github.com/zhiern/openwrt_caches/releases/download/openwrt-24.10
    curl -L ${TOOLCHAIN_URL}/toolchain_musl_${toolchain_arch}_gcc-${gcc_version}.tar.zst -o toolchain.tar.zst $CURL_BAR
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -I "zstd" -xf toolchain.tar.zst
    rm -f toolchain.tar.zst
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# init openwrt config
rm -rf tmp/*
if [ "$BUILD" = "n" ]; then
    exit 0
else
    make defconfig
fi

# Compile
if [ "$BUILD_TOOLCHAIN" = "y" ]; then
    echo -e "\r\n${GREEN_COLOR}Building Toolchain ...${RES}\r\n"
    make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1
    mkdir -p toolchain-cache
    tar -I "zstd -19 -T$(nproc --all)" -cf toolchain-cache/toolchain_musl_${toolchain_arch}_gcc-${gcc_version}.tar.zst ./{build_dir,dl,staging_dir,tmp}
    echo -e "\n${GREEN_COLOR} Build success! ${RES}"
    exit 0
else
    echo -e "\r\n${GREEN_COLOR}Building OpenWrt ...${RES}\r\n"
    sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
    sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
    make -j$cores IGNORE_ERRORS="n m"
fi

# Compile time
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
SEC=$((end_seconds-start_seconds));

if [ -f bin/targets/*/*/sha256sums ]; then
    echo -e "${GREEN_COLOR} Build success! ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
else
    echo -e "\n${RED_COLOR} Build error... ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
    echo
    exit 1
fi

if [ "$platform" = "x86_64" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        mkdir kmodpkg
        cp -a bin/targets/x86/*/packages $kmodpkg_name/
        rm -f kmodpkg/Packages*
        cp -a bin/packages/x86_64/base/rtl88*a-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/x86_64/base/natflow*.ipk $kmodpkg_name/
        bash kmod-sign $kmodpkg_name
        tar zcf x86_64-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "v24" ]; then
        mkdir -p ota
        OTA_URL="https://github.com/zhiern/ZeroWrt/releases/download"
        VERSION=$(sed 's/v//g' version.txt)
        SHA256=$(sha256sum bin/targets/x86/64*/*-generic-squashfs-combined-efi.img.gz | awk '{print $1}')
        cat > ota/x86_64.json <<EOF
{
  "x86_64": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-x86-64-generic-squashfs-combined-efi.img.gz"
    }
  ]
}
EOF
    fi
elif [ "$platform" = "rockchip" ]; then
    if [ "$NO_KMOD" != "y" ]; then
        mkdir kmodpkg
        cp -a bin/targets/rockchip/armv8*/packages $kmodpkg_name
        rm -f kmodpkg/Packages*
        cp -a bin/packages/aarch64_generic/base/rtl88*-firmware*.ipk $kmodpkg_name/
        cp -a bin/packages/aarch64_generic/base/natflow*.ipk $kmodpkg_name/
        bash kmod-sign $kmodpkg_name
        tar zcf armv8-$kmodpkg_name.tar.gz $kmodpkg_name
        rm -rf $kmodpkg_name
    fi
    # OTA json
    if [ "$1" = "v24" ]; then
        mkdir -p ota
        OTA_URL="https://github.com/zhiern/ZeroWrt/releases/download"
        VERSION=$(sed 's/v//g' version.txt)
        SHA256_armsom_sige3=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-armsom_sige3-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_armsom_sige7=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-armsom_sige7-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_t4=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopc-t4-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_t6=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopc-t6-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r2c_plus=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r2c-plus-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r2c=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r2c-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r2s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r3s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r3s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r4s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r4s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r4se=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r4se-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r5c=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r5c-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r5s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r5s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r6c=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r6c-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r6s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-friendlyarm_nanopi-r6s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_huake_guangmiao_g4c=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-huake_guangmiao-g4c-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r66s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-lunzn_fastrhino-r66s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_r68s=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-lunzn_fastrhino-r68s-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_radxa_rock_5a=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-radxa_rock-5a-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_radxa_rock_5b=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-radxa_rock-5b-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_xunlong_orangepi_5_plus=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-xunlong_orangepi-5-plus-squashfs-sysupgrade.img.gz | awk '{print $1}')
        SHA256_xunlong_orangepi_5=$(sha256sum bin/targets/rockchip/armv8*/openwrt-24.10.2-rockchip-armv8-xunlong_orangepi-5-squashfs-sysupgrade.img.gz | awk '{print $1}')
        cat > ota/rockchip.json <<EOF
{
  "armsom,sige3": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_armsom_sige3",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-armsom_sige3-squashfs-sysupgrade.img.gz"
    }
  ],
  "armsom,sige7": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_armsom_sige7",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-armsom_sige7-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopc-t4": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_t4",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopc-t4-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopc-t6": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_t6",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopc-t6-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r2c-plus": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r2c_plus",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r2c-plus-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r2c": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r2c",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r2c-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r2s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r2s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r2s-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r3s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r3s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r3s-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r4s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r4s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r4s-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r4se": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r4se",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r4se-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r5c": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r5c",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r5c-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r5s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r5s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r5s-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r6c": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r6c",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r6c-squashfs-sysupgrade.img.gz"
    }
  ],
  "friendlyarm,nanopi-r6s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r6s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r6s-squashfs-sysupgrade.img.gz"
    }
  ],
  "huake,guangmiao-g4c": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_huake_guangmiao_g4c",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-huake_guangmiao-g4c-squashfs-sysupgrade.img.gz"
    }
  ],
  "lunzn,fastrhino-r66s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r66s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-lunzn_fastrhino-r66s-squashfs-sysupgrade.img.gz"
    }
  ],
  "lunzn,fastrhino-r68s": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_r68s",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-lunzn_fastrhino-r68s-squashfs-sysupgrade.img.gz"
    }
  ],
  "radxa,rock-5a": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_radxa_rock_5a",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-radxa_rock-5a-squashfs-sysupgrade.img.gz"
    }
  ],
  "radxa,rock-5b": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_radxa_rock_5b",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-radxa_rock-5b-squashfs-sysupgrade.img.gz"
    }
  ],
  "xunlong,orangepi-5-plus": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_xunlong_orangepi_5_plus",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-xunlong_orangepi-5-plus-squashfs-sysupgrade.img.gz"
    }
  ],
  "xunlong,orangepi-5": [
    {
      "build_date": "$CURRENT_DATE",
      "sha256sum": "$SHA256_xunlong_orangepi_5",
      "url": "$OTA_URL/OpenWrt-v$VERSION/openwrt-$VERSION-rockchip-armv8-xunlong_orangepi-5-squashfs-sysupgrade.img.gz"
    }
  ]
}
EOF
    fi
fi        
### People come and go, we struggled with laughter and tears,and all the years have gone by,still Ihave you by my side. 你陪了我多少年，花开花落。一路上起起跌跌 ###
