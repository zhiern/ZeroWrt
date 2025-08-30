#!/bin/bash
# ====== OpenWrt Build Start Notification ======
# 外部传入环境变量：
# RELEASE_TAG, COMPILE_TYPE, GCC_VERSION, WEB_SERVER, DOCKER, LAN_ADDR, ROOT_PASSWORD, BUILD_OPTIONS, TGID, TG_TOKEN, PUSHKEY, PUSHSERVE

# ====== 获取系统信息 ======
CPU_MODEL="$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ //')"
CPU_CORES="$(grep -c '^processor' /proc/cpuinfo)"
CPU_FREQ="$(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk -F ': ' '{print $2}' | cut -d'.' -f1)"
MEM_TOTAL="$(free -h | grep Mem | awk '{print $2}')"
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# ====== 构建消息 ======
MESSAGE="💻 主人，新的 OpenWrt 编译任务已经启动！

📦 固件版本：${RELEASE_TAG}
🔧 编译类型：${COMPILE_TYPE}
  • GCC版本：${GCC_VERSION}
  • Web服务：${WEB_SERVER}
  • Docker支持：${DOCKER}
  • LAN地址：${LAN_ADDR}
  • Root密码：${ROOT_PASSWORD}
  • 构建选项：${BUILD_OPTIONS}

🖥️ 当前编译环境：
  • CPU：$CPU_MODEL @ ${CPU_FREQ}MHz × $CPU_CORES
  • 内存：$MEM_TOTAL
  • 系统启动时间：$START_TIME

⚠️ 已知高性能CPU型号参考（降序）：7763, 8370C, 8272CL, 8171M, E5-2673

请耐心等待编译完成…… 😋💐"

# ====== 输出到终端 ======
echo "========================================"
echo "$MESSAGE"
echo "========================================"

# ====== 推送消息（Telegram） ======
if [[ -n "$TGID" && -n "$TG_TOKEN" ]]; then
    curl -s -k --data chat_id="${TGID}" \
         --data "text=$MESSAGE" \
         "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
fi

# ====== 推送消息（PushDeer） ======
if [[ -n "$PUSHKEY" && -n "$PUSHSERVE" ]]; then
    curl -s -k --data "pushkey=${PUSHKEY}" \
         --data "text=${MESSAGE}" \
         "https://${PUSHSERVE}/message/push"
fi

# ====== 提示未配置通知 ======
if [[ -z "$TGID" || -z "$TG_TOKEN" ]] && [[ -z "$PUSHKEY" || -z "$PUSHSERVE" ]]; then
    echo "⚠️ 未配置 Telegram 或 PushDeer，消息仅输出到终端"
fi
