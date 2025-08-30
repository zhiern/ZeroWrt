#!/bin/bash
# ====== OpenWrt Build End Notification ======
# 外部传入环境变量：
# RELEASE_TAG, KERNEL_VERSION, TGID, TG_TOKEN, PUSHKEY, PUSHSERVE, RELEASE_LINK

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
FIRMWARE_URL="${RELEASE_LINK}"

# ====== 构建消息 ======
MESSAGE="🎉 主人，您的 OpenWrt 固件编译已完成！
📦 固件版本：${RELEASE_TAG}-${KERNEL_VERSION}-$(date +"%Y.%m.%d-%H%M")
⏰ 完成时间：$END_TIME
🔗 下载链接：$FIRMWARE_URL

请注意检查固件完整性并根据需要刷入设备 😊💐"

# ====== 输出到终端 ======
echo "========================================"
echo "$MESSAGE"
echo "========================================"

# ====== Telegram 推送 ======
if [[ -n "$TGID" && -n "$TG_TOKEN" ]]; then
    curl -s -k --data chat_id="${TGID}" \
         --data "text=$MESSAGE" \
         "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
fi

# ====== PushDeer 推送 ======
if [[ -n "$PUSHKEY" && -n "$PUSHSERVE" ]]; then
    curl -s -k --data "pushkey=${PUSHKEY}" \
         --data "text=${MESSAGE}" \
         "https://${PUSHSERVE}/message/push"
fi

# ====== 提示未配置通知 ======
if [[ -z "$TGID" || -z "$TG_TOKEN" ]] && [[ -z "$PUSHKEY" || -z "$PUSHSERVE" ]]; then
    echo "⚠️ 未配置 Telegram 或 PushDeer，消息仅输出到终端"
fi

