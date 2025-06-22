#!/bin/bash

# =====================
# 配置参数
# =====================

# 脚本URL
export mirror=https://script.kejizero.online

# 私有Gitea
export gitea=git.kejizero.online/zhao

# GitHub镜像
export github="github.com"

# 修改默认ip
sed -i "s/192.168.1.1/10.0.0.1/g" package/base-files/files/bin/config_generate
sed -i "s/192.168.1.1/10.0.0.1/g" package/base-files/luci2/bin/config_generate

# 修改名称
sed -i 's/LEDE/ZeroWrt/' package/base-files/files/bin/config_generate
sed -i 's/LEDE/ZeroWrt/' package/base-files/luci2/bin/config_generate

# 修改内核版本
sed -i 's/6.6/6.12/' target/linux/qualcommax/Makefile

##WiFi
sed -i "s/LEDE/ZeroWrt/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# banner
curl -s $mirror/Customize/base-files/banner > package/base-files/files/etc/banner

# key-build.pub
mkdir -p files/root
curl -so files/root/key-build.pub $mirror/openwrt/files/root/key-build.pub
chmod +x files/root/key-build.pub

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

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
sed -i 's|^OPENWRT_RELEASE=".*"|OPENWRT_RELEASE="ZeroWrt 标准版 @R250605 BY OPPEN321"|' package/base-files/files/usr/lib/os-release

# distfeeds.conf
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/aarch64_cortex-a53/telephony
EOF

# golang 1.24
rm -rf feeds/packages/lang/golang
git clone https://$GITEA_USERTNAME:$GITEA_PASSWORD@$gitea/packages_lang_golang -b 24.x feeds/packages/lang/golang

# SSRP & Passwall
rm -rf feeds/luci/applications/{luci-app-passwall.luci-app-passwall2,luci-app-openclash}
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,pdnsd-alt}
git clone -b openwrt-24.10 https://$GITEA_USERTNAME:$GITEA_PASSWORD@$gitea/openwrt_helloworld package/new/helloworld

# Mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/utils/v2dat
git clone https://$github/sbwml/luci-app-mosdns -b v5 package/new/mosdns

# adguardhome
rm -rf feeds/luci/applications/luci-app-adguardhome
git clone https://$GITEA_USERTNAME:$GITEA_PASSWORD@$gitea/luci-app-adguardhome package/new/luci-app-adguardhome

# luci-app-sqm
rm -rf feeds/luci/applications/luci-app-sqm
git clone https://$GITEA_USERTNAME:$GITEA_PASSWORD@$gitea/luci-app-sqm feeds/luci/applications/luci-app-sqm

# argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
curl -s $mirror/Customize/argon/bg1.jpg > package/new/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# argon-config
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
sed -i "s/bing/none/g" package/new/luci-app-argon-config/root/etc/config/argon

# 主题设置
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">OpenWRT</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">OpenWRT</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# default-settings
rm -rf package/lean/default-settings
git clone --depth=1 -b ipq https://github.com/zhiern/default-settings package/new/default-settings

# install feeds
./scripts/feeds update -a
./scripts/feeds install -a
