#!/bin/bash

# kernel - 6.12
curl -s https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/kernel-6.12/tags/kernel-6.12 > include/kernel-6.12

# x86_64 - target 6.12
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/64/config-6.12 > target/linux/x86/64/config-6.12
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/config-6.12 > target/linux/x86/config-6.12
mkdir -p target/linux/x86/patches-6.12
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/100-fix_cs5535_clockevt.patch > target/linux/x86/patches-6.12/100-fix_cs5535_clockevt.patch
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/103-pcengines_apu6_platform.patch > target/linux/x86/patches-6.12/103-pcengines_apu6_platform.patch
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/992-enable-intel-guc.patch > target/linux/x86/patches-6.12/992-enable-intel-guc.patch
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/993-bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch > target/linux/x86/patches-6.12/993-bnx2x_warpcore_8727_2_5g_sgmii_txfault.patch
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/996-intel-igc-i225-i226-disable-eee.patch > target/linux/x86/patches-6.12/996-intel-igc-i225-i226-disable-eee.patch
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/patches-6.12/999-Add-xtsproxy-Crypto-API-module.patch > target/linux/x86/patches-6.12/999-Add-xtsproxy-Crypto-API-module.patch

# x86_64 - target
sed -ri "s/(KERNEL_PATCHVER:=)[^\"]*/\16.12/" target/linux/x86/Makefile
sed -i '/KERNEL_PATCHVER/a\KERNEL_TESTING_PATCHVER:=6.6' target/linux/x86/Makefile
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/base-files/etc/board.d/01_leds > target/linux/x86/base-files/etc/board.d/01_leds
curl -s https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/target/linux/x86/base-files/etc/board.d/02_network > target/linux/x86/base-files/etc/board.d/02_network

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/PS1/a\export TERM=xterm-color' package/base-files/files/etc/profile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://git.kejizero.online/zhao/files/raw/branch/main/root/.bash_profile
curl -so files/root/.bashrc https://git.kejizero.online/zhao/files/raw/branch/main/root/.bashrc

# mwan3
sed -i 's/MultiWAN 管理器/负载均衡/g' feeds/luci/applications/luci-app-mwan3/po/zh_Hans/mwan3.po

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,adguardhome,socat}
rm -rf feeds/packages/net/alist feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# golong1.23依赖
#git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# SSRP & Passwall
git clone https://git.kejizero.online/zhao/openwrt_helloworld.git package/helloworld -b v5

# nginx
rm -rf feeds/packages/net/nginx
git clone https://github.com/sbwml/feeds_packages_net_nginx -b openwrt-24.10 feeds/packages/net/nginx

# IPv6 NAT
git clone https://github.com/sbwml/packages_new_nat6 package/nat6

# Alist
git clone https://git.kejizero.online/zhao/luci-app-alist package/alist

# Mosdns
git clone https://git.kejizero.online/zhao/luci-app-mosdns.git -b v5 package/mosdns
git clone https://git.kejizero.online/zhao/v2ray-geodata.git package/v2ray-geodata

# 锐捷认证
git clone https://github.com/sbwml/luci-app-mentohust package/mentohust

# istoreos-files
git clone https://github.com/oppen321/istoreos-files package/istoreos-files

# Realtek 网卡 - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/r8168 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
git clone https://git.kejizero.online/zhao/package_kernel_r8168 package/kernel/r8168
git clone https://git.kejizero.online/zhao/package_kernel_r8152 package/kernel/r8152
git clone https://git.kejizero.online/zhao/package_kernel_r8101 package/kernel/r8101
git clone https://git.kejizero.online/zhao/package_kernel_r8125 package/kernel/r8125
git clone https://git.kejizero.online/zhao/package_kernel_r8126 package/kernel/r8126

# Adguardhome
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome

# smartdns
rm -rf feeds/{packages/netsmartdns,luci/applications/luci-app-smartdns}
git_sparse_clone master https://github.com/kenzok8/openwrt-packages smartdns luci-app-smartdns

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://git.kejizero.online/zhao/luci-app-dockerman -b 24.10 feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://git.kejizero.online/zhao/packages_utils_docker feeds/packages/utils/docker
git clone https://git.kejizero.online/zhao/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://git.kejizero.online/zhao/packages_utils_containerd feeds/packages/utils/containerd
git clone https://git.kejizero.online/zhao/packages_utils_runc feeds/packages/utils/runc
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://init.cooluc.com/openwrt/patch/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s https://init.cooluc.com/openwrt/patch/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s https://init.cooluc.com/openwrt/patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://git.kejizero.online/zhao/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone https://git.kejizero.online/zhao/luci-app-upnp feeds/luci/applications/luci-app-upnp -b master

# Zero-package
git clone --depth=1 https://github.com/oppen321/Zero-package package/Zero-package

# 修改名称
sed -i 's/OpenWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# Theme
# git clone --depth 1 https://github.com/sbwml/luci-theme-argon package/luci-theme-argon
# git clone https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat -b js
# curl -L -o package/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/img/bg.webp https://git.kejizero.online/zhao/files/raw/branch/main/%20background/bg.webp
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
sed -i "s/option online_wallpaper 'bing'/option online_wallpaper 'none'/g" package/luci-app-argon-config/root/etc/config/argon

# default-settings
git clone --depth=1 -b openwrt-24.10 https://github.com/oppen321/default-settings package/default-settings

# Lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# OpenAppFilter
git clone https://git.kejizero.online/zhao/OpenAppFilter --depth=1 package/OpenAppFilter

# luci-app-webdav
git clone https://git.kejizero.online/zhao/luci-app-webdav package/new/luci-app-webdav

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# frpc名称
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,FRP 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,FRP 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

./scripts/feeds update -a
./scripts/feeds install -a
