#!/bin/bash
# ====== OpenWrt Build Start Notification ======

CPU_MODEL="$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ //')"
CPU_CORES="$(grep -c '^processor' /proc/cpuinfo)"
CPU_FREQ="$(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk -F ': ' '{print $2}' | cut -d'.' -f1)"
MEM_TOTAL="$(free -h | grep Mem | awk '{print $2}')"
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

MESSAGE="💻 主人，新的 OpenWrt 编译任务已经启动！

📦 固件版本：${RELEASE_TAG}
🔧 编译参数：
  • GCC版本：${{ github.event.inputs.gcc_version }}
  • Web服务：${{ github.event.inputs.web_server }}
  • Docker支持：${{ github.event.inputs.docker }}
  • LAN地址：${{ github.event.inputs.lan_addr }}
  • Root密码：${{ github.event.inputs.root_password }}
  • 构建选项：${{ github.event.inputs.build_options }}

🖥️ 当前编译环境：
  • CPU：$CPU_MODEL @ ${CPU_FREQ}MHz × $CPU_CORES
  • 内存：$MEM_TOTAL
  • 系统启动时间：$START_TIME

⚠️ 已知高性能CPU型号参考（降序）：7763, 8370C, 8272CL, 8171M, E5-2673

请耐心等待编译完成…… 😋💐"

# Telegram 推送
curl -k --data chat_id=${{ secrets.TGID }} \
     --data "text=$MESSAGE" \
     "https://api.telegram.org/bot${{ secrets.TG_TOKEN }}/sendMessage"

# PushDeer 推送（可选）
curl -k --data pushkey="${{ secrets.pushkey }}" \
     --data "text=OpenWrt 编译启动通知" \
     --data "desp=$MESSAGE" \
     "https://${{ secrets.pushserve }}/message/push?"
