#!/bin/bash -e

#################################################################

# autocore
git clone https://$github/sbwml/autocore-arm -b openwrt-24.10 package/system/autocore

# rockchip - target
rm -rf target/linux/rockchip
if [ "$(whoami)" = "zhao" ]; then
    git clone $gitea/zhao/target_linux_rockchip target/linux/rockchip -b openwrt-24.10
else
    git clone https://"$git_name":"$git_password"@$gitea/zhao/target_linux_rockchip target/linux/rockchip -b openwrt-24.10
fi

# x86 - target
rm -rf target/linux/x86
if [ "$(whoami)" = "zhao" ]; then
    git clone $gitea/zhao/target_linux_x86 target/linux/x86 -b openwrt-24.10
else
    git clone https://"$git_name":"$git_password"@$gitea/zhao/target_linux_x86 target/linux/x86 -b openwrt-24.10
fi

# generic - target
rm -rf target/linux/generic
if [ "$(whoami)" = "zhao" ]; then
    git clone $gitea/zhao/target_linux_generic target/linux/generic -b openwrt-24.10
else
    git clone https://"$git_name":"$git_password"@$gitea/zhao/target_linux_generic target/linux/generic -b openwrt-24.10
fi

# make olddefconfig
curl -sL $mirror/doc/patch/kernel-6.6/kernel/0003-include-kernel-defaults.mk.patch | patch -p1

# banner
curl -s $mirror/Customize/base-files/banner > package/base-files/files/etc/banner

# kernel - 6.12
curl -s $mirror/tags/kernel-6.6 > include/kernel-6.6

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH include/kernel-6.6 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# BBRv3 - linux-6.6
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

# LRNG - 6.6
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
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-01-v57-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-02-v57-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-03-v57-0003-LRNG-proc-interface.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-04-v57-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-05-v57-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-06-v57-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-07-v57-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-08-v57-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-09-v57-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-10-v57-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-11-v57-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-12-v57-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-13-v57-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-14-v57-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-15-v57-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-16-v57-0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-17-v57-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-18-v57-0018-LRNG-add-option-to-enable-runtime-entropy-rate-c.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-19-v57-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-20-v57-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-21-v57-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-22-v57-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-23-v57-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-24-v57-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-25-v57-0025-LRNG-add-hwrand-framework-interface.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-26-v57-01-config_base_small.patch
    curl -Os $mirror/doc/patch/kernel-6.6/lrng/696-27-v57-02-sysctl-unconstify.patch
popd

# linux-firmware
rm -rf package/firmware/linux-firmware
git clone https://$github/sbwml/package_firmware_linux-firmware package/firmware/linux-firmware

# mt76
mkdir -p package/kernel/mt76/patches
curl -s $mirror/openwrt/patch/mt76/Makefile > package/kernel/mt76/Makefile
curl -s $mirror/openwrt/patch/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch > package/kernel/mt76/patches/100-fix-build-with-mac80211-6.11-backport.patch
curl -s $mirror/openwrt/patch/mt76/patches/101-fix-build-with-linux-6.12rc2.patch > package/kernel/mt76/patches/101-fix-build-with-linux-6.12rc2.patch
curl -s $mirror/openwrt/patch/mt76/patches/102-fix-build-with-mac80211-6.14-backport.patch > package/kernel/mt76/patches/102-fix-build-with-mac80211-6.14-backport.patch

# wireless-regdb
curl -s $mirror/openwrt/patch/openwrt-6.x/500-world-regd-5GHz.patch > package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch

# mac80211 - 6.15.6
rm -rf package/kernel/mac80211
git clone https://$github/sbwml/package_kernel_mac80211 package/kernel/mac80211 -b openwrt-24.10

# ath10k-ct
rm -rf package/kernel/ath10k-ct
git clone https://$github/sbwml/package_kernel_ath10k-ct package/kernel/ath10k-ct -b v6.15

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

# rtl8822cs
git clone https://$github/sbwml/package_kernel_rtl8822cs package/kernel/rtl8822cs
