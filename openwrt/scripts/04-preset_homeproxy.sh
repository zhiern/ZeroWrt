#!/bin/bash

# 设置变量
HP_RULE="surge"
HP_PATH="package/new/helloworld/luci-app-homeproxy/root/etc/homeproxy"

# 移除旧版本规则
rm -rf $HP_PATH/resources/*

# 克隆 surge-rules 仓库
git clone -q --depth=1 --single-branch --branch "release" "https://github.com/zhiern/rules.git" $HP_RULE
RES_VER=$(git -C "$HP_RULE" log -1 --pretty=format:'%s' | grep -o "[0-9]*")

# 写版本号到多个文件
echo "$RES_VER" | tee "$HP_RULE/china_ip4.ver" "$HP_RULE/china_ip6.ver" "$HP_RULE/china_list.ver" "$HP_RULE/gfw_list.ver"

# 处理 cncidr.txt（假设文件在 $HP_RULE 目录下）
awk -F, -v hp="$HP_RULE" '/^IP-CIDR,/ {print $2 > (hp "/china_ip4.txt")} /^IP-CIDR6,/ {print $2 > (hp "/china_ip6.txt")}' "$HP_RULE/cncidr.txt"

# 处理 direct.txt 和 gfw.txt
sed 's/^\.//g' "$HP_RULE/direct.txt" > "$HP_RULE/china_list.txt"
sed 's/^\.//g' "$HP_RULE/gfw.txt" > "$HP_RULE/gfw_list.txt"

# 移动并替换
mv -f $HP_RULE/{china_*,gfw_list}.{ver,txt} $HP_PATH/resources
