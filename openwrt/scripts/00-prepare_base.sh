#!/bin/bash -e

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk

# 内核版本设置
curl -s $mirror/tags/kernel-6.6 > include/kernel-6.6
curl -s $mirror/openwrt/patch/kernel-6.6/kernel/0001-linux-module-video.patch > package/0001-linux-module-video.patch
git apply package/0001-linux-module-video.patch
rm -rf package/0001-linux-module-video.patch

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-6.6 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

# patch source
curl -s $mirror/openwrt/patch/generic-24.10/0001-tools-add-upx-tools.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-24.10/0002-rootfs-add-upx-compression-support.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-24.10/0003-rootfs-add-r-w-permissions-for-UCI-configuration-fil.patch | patch -p1
curl -s $mirror/openwrt/patch/generic-24.10/0004-rootfs-Add-support-for-local-kmod-installation-sourc.patch | patch -p1

### 获取额外的基础软件包 ###
# rockchip - target
rm -rf package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
rm -rf target/linux/rockchip
cp -rf ../immortalwrt/target/linux/rockchip target/linux/rockchip
cp -rf ../immortalwrt/package/boot/uboot-rockchip package/boot/uboot-rockchip
cp -rf ../immortalwrt/package/boot/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
sed -i '/REQUIRE_IMAGE_METADATA/d' target/linux/rockchip/armv8/base-files/lib/upgrade/platform.sh

### FW4 ###
curl -s $mirror/openwrt/doc/firewall4/Makefile > package/network/config/firewall4/Makefile
sed -i 's|$(PROJECT_GIT)/project|https://github.com/openwrt|g' package/network/config/firewall4/Makefile
mkdir -p package/network/config/firewall4/patches

# add custom nft command support
curl -s $mirror/openwrt/patch/firewall4/100-openwrt-firewall4-add-custom-nft-command-support.patch | patch -p1

# fix ct status dnat
curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/990-unconditionally-allow-ct-status-dnat.patch > package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch

# fullcone
curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/999-01-firewall4-add-fullcone-support.patch > package/network/config/firewall4/patches/999-01-firewall4-add-fullcone-support.patch

# bcm fullcone
curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/999-02-firewall4-add-bcm-fullconenat-support.patch > package/network/config/firewall4/patches/999-02-firewall4-add-bcm-fullconenat-support.patch

# fix flow offload
curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/001-fix-fw4-flow-offload.patch > package/network/config/firewall4/patches/001-fix-fw4-flow-offload.patch

# fw4 add custom nft command support
curl -s $mirror/openwrt/patch/firewall4/firewall4_patches/100-fw4-add-custom-nft-command-support.patch > package/network/config/firewall4/patches/100-fw4-add-custom-nft-command-support.patch

# libnftnl
mkdir -p package/libs/libnftnl/patches
curl -s $mirror/openwrt/patch/firewall4/libnftnl/0001-libnftnl-add-fullcone-expression-support.patch > package/libs/libnftnl/patches/0001-libnftnl-add-fullcone-expression-support.patch
curl -s $mirror/openwrt/patch/firewall4/libnftnl/0002-libnftnl-add-brcm-fullcone-support.patch > package/libs/libnftnl/patches/0002-libnftnl-add-brcm-fullcone-support.patch

# kernel patch
# btf: silence btf module warning messages
curl -s $mirror/openwrt/patch/kernel-6.6/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.6/990-btf-silence-btf-module-warning-messages.patch
# cpu model
curl -s $mirror/openwrt/patch/kernel-6.6/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# fullcone
curl -s $mirror/openwrt/patch/kernel-6.6/net/952-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.6/952-net-conntrack-events-support-multiple-registrant.patch
# bcm-fullcone
curl -s $mirror/openwrt/patch/kernel-6.6/net/982-add-bcm-fullcone-support.patch > target/linux/generic/hack-6.6/982-add-bcm-fullcone-support.patch
curl -s $mirror/openwrt/patch/kernel-6.6/net/983-add-bcm-fullcone-nft_masq-support.patch > target/linux/generic/hack-6.6/983-add-bcm-fullcone-nft_masq-support.patch
# shortcut-fe
curl -s $mirror/openwrt/patch/kernel-6.6/net/601-netfilter-export-udp_get_timeouts-function.patch > target/linux/generic/hack-6.6/601-netfilter-export-udp_get_timeouts-function.patch
curl -s $mirror/openwrt/patch/kernel-6.6/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.6/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# nftables
mkdir -p package/network/utils/nftables/patches
curl -s $mirror/openwrt/patch/firewall4/nftables/0001-nftables-add-fullcone-expression-support.patch > package/network/utils/nftables/patches/0001-nftables-add-fullcone-expression-support.patch
curl -s $mirror/openwrt/patch/firewall4/nftables/0002-nftables-add-brcm-fullconenat-support.patch > package/network/utils/nftables/patches/0002-nftables-add-brcm-fullconenat-support.patch
curl -s $mirror/openwrt/patch/firewall4/nftables/0003-drop-rej-file.patch > package/network/utils/nftables/patches/0003-drop-rej-file.patch

# FullCone module
git clone https://$gitea/zhao/nft-fullcone package/new/nft-fullcone

# IPv6 NAT
git clone https://$github/sbwml/packages_new_nat6 package/new/nat6

# Natflow
git clone https://$github/sbwml/package_new_natflow package/new/natflow

# Shortcut Forwarding Engine
git clone https://$gitea/zhao/shortcut-fe package/new/shortcut-fe

# ARM64 型号名称
curl -s $mirror/openwrt/patch/arm64/kernel-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

# BBRv3
pushd target/linux/generic/backport-6.6
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/bbr3/010-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
popd

# LRNG
echo '
# CONFIG_RANDOM_DEFAULT_IMPL is not set
CONFIG_LRNG=y
CONFIG_LRNG_DEV_IF=y
# CONFIG_LRNG_IRQ is not set
CONFIG_LRNG_JENT=y
CONFIG_LRNG_CPU=y
# CONFIG_LRNG_SCHED is not set
CONFIG_LRNG_SELFTEST=y
# CONFIG_LRNG_SELFTEST_PANIC is not set
' >>./target/linux/generic/config-6.6
pushd target/linux/generic/hack-6.6
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-01-v59-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-02-v59-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-03-v59-0003-LRNG-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-04-v59-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-05-v59-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-06-v59-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-07-v59-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-08-v59-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-09-v59-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-10-v59-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-11-v59-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-12-v59-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-13-v59-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-14-v59-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-15-v59-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-16-v59-0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-17-v59-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-18-v59-0018-LRNG-add-option-to-enable-runtime-entropy-rate-c.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-19-v59-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-20-v59-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-21-v59-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-22-v59-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-23-v59-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-24-v59-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-25-v59-0025-LRNG-add-hwrand-framework-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-26-v59-01-config_base_small.patch
    curl -Os $mirror/openwrt/patch/kernel-6.6/lrng/696-27-v59-02-sysctl-unconstify.patch
popd

### Other Kernel Hack 部分 ###
# make olddefconfig
curl -sL $mirror/openwrt/patch/kernel-6.6/kernel/0003-include-kernel-defaults.mk.patch | patch -p1
# igc-fix
curl -s $mirror/openwrt/patch/kernel-6.6/igc-fix/996-intel-igc-i225-i226-disable-eee.patch > target/linux/x86/patches-6.6/996-intel-igc-i225-i226-disable-eee.patch
# btf
curl -s $mirror/openwrt/patch/kernel-6.6/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.6/990-btf-silence-btf-module-warning-messages.patch

# 6.17_ppp_performance
wget https://github.com/torvalds/linux/commit/95d0d09.patch -O target/linux/generic/pending-6.6/999-1-95d0d09.patch
wget https://github.com/torvalds/linux/commit/1a3e9b7.patch -O target/linux/generic/pending-6.6/999-2-1a3e9b7.patch
wget https://github.com/torvalds/linux/commit/7eebd21.patch -O target/linux/generic/pending-6.6/999-3-7eebd21.patch

# ppp_fix
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/9d852a0.patch | patch -p1

### 个性化修改 ###
sed -i "s/192.168.1.1/$LAN/g" package/base-files/files/bin/config_generate

if [ -n "$ROOT_PASSWORD" ]; then
    # sha256 encryption
    default_password=$(openssl passwd -5 $ROOT_PASSWORD)
    sed -i "s|^root:[^:]*:|root:${default_password}:|" package/base-files/files/etc/shadow
fi

sed -i 's/OpenWrt/ZeroWrt/' package/base-files/files/bin/config_generate

curl -s $mirror/openwrt/doc/base-files/banner > package/base-files/files/etc/banner

sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile

# Distfeeds.conf
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/$opkg/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/$opkg/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/$opkg/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/$opkg/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/$opkg/telephony
EOF

# Patch Luci add nft_fullcone/bcm_fullcone & shortcut-fe & natflow & ipv6-nat & custom nft command option
pushd feeds/luci
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone-.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0002-luci-app-firewall-add-shortcut-fe-option.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0003-luci-app-firewall-add-ipv6-nat-option.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0004-luci-add-firewall-add-custom-nft-rule-support.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0005-luci-app-firewall-add-natflow-offload-support.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0006-luci-app-firewall-enable-hardware-offload-only-on-de.patch | patch -p1
    curl -s $mirror/openwrt/patch/firewall4/luci-24.10/0007-luci-app-firewall-add-fullcone6-option-for-nftables-.patch | patch -p1
popd

# luci-mod extra
pushd feeds/luci
    curl -s $mirror/openwrt/patch/luci/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1
    curl -s $mirror/openwrt/patch/luci/0007-luci-mod-system-add-ucitrack-luci-mod-system-zram.js.patch | patch -p1
popd

# opkg
mkdir -p package/system/opkg/patches
curl -s $mirror/openwrt/patch/opkg/900-opkg-download-disable-hsts.patch > package/system/opkg/patches/900-opkg-download-disable-hsts.patch
curl -s $mirror/openwrt/patch/opkg/901-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch > package/system/opkg/patches/901-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/ENV/i\export TERM=xterm-color' package/base-files/files/etc/profile

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile $mirror/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc $mirror/openwrt/files/root/.bashrc

# rootfs files
mkdir -p files/etc/sysctl.d
mkdir -p files/etc/hotplug.d/iface
mkdir -p files/etc/hotplug.d/net
curl -so files/etc/sysctl.d/10-default.conf $mirror/openwrt/files/etc/sysctl.d/10-default.conf
curl -so files/etc/sysctl.d/15-vm-swappiness.conf $mirror/openwrt/files/etc/sysctl.d/15-vm-swappiness.conf
curl -so files/etc/sysctl.d/16-udp-buffer-size.conf $mirror/openwrt/files/etc/sysctl.d/16-udp-buffer-size.conf
curl -so files/etc/hotplug.d/iface/99-zzz-odhcpd $mirror/openwrt/files/etc/hotplug.d/iface/99-zzz-odhcpd
curl -so files/etc/hotplug.d/net/01-maximize_nic_rx_tx_buffers  $mirror/openwrt/files/etc/hotplug.d/net/01-maximize_nic_rx_tx_buffers

# ZeroWrt Options Menu
mkdir -p files/bin
curl -so files/root/version.txt $mirror/openwrt/files/root/version.txt
curl -so files/bin/ZeroWrt $mirror/openwrt/files/bin/ZeroWrt
chmod +x files/bin/ZeroWrt
chmod +x files/root/version.txt

# key-build.pub
curl -so files/root/key-build.pub https://opkg.kejizero.online/key-build.pub
chmod +x files/root/key-build.pub

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# luci-theme-bootstrap
sed -i 's/font-size: 13px/font-size: 14px/g' feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css
sed -i 's/9.75px/10.75px/g' feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css

# 版本设置
cat << 'EOF' >> feeds/luci/modules/luci-mod-status/ucode/template/admin_status/index.ut
<script>
function addLinks() {
    var section = document.querySelector(".cbi-section");
    if (section) {
        var links = document.createElement('div');
        links.innerHTML = '<div class="table"><div class="tr"><div class="td left" width="33%"><a href="https://qm.qq.com/q/JbBVnkjzKa" target="_blank">QQ交流群</a></div><div class="td left" width="33%"><a href="https://t.me/kejizero" target="_blank">TG交流群</a></div><div class="td left"><a href="https://openwrt.kejizero.online" target="_blank">固件地址</a></div></div></div>';
        section.appendChild(links);
    } else {
        setTimeout(addLinks, 100); // 继续等待 `.cbi-section` 加载
    }
}

document.addEventListener("DOMContentLoaded", addLinks);
</script>
EOF

# 加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By OPPEN321'/g" package/base-files/files/etc/openwrt_release
sed -i "s|^OPENWRT_RELEASE=\".*\"|OPENWRT_RELEASE=\"ZeroWrt 标准版 @R$(date +%Y%m%d) BY OPPEN321\"|" package/base-files/files/usr/lib/os-release
