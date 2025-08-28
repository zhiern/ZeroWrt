#!/bin/bash
# ====== OpenWrt Build End Notification ======

# 外部传入环境变量：
# RELEASE_TAG, KERNEL_VERSION, TGID, TG_TOKEN, PUSHKEY, PUSHSERVE, RELEASE_LINK

END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
FIRMWARE_URL="${RELEASE_LINK}"

MESSAGE="🎉 主人，您的 OpenWrt 固件编译已完成！
📦 固件版本：${RELEASE_TAG}-${KERNEL_VERSION}-$(date +"%Y.%m.%d-%H%M")
⏰ 完成时间：$END_TIME
🔗 下载链接：$FIRMWARE_URL

请注意检查固件完整性并根据需要刷入设备 😊💐"

# Telegram 推送
curl -k --data chat_id=${TGID} \
     --data "text=$MESSAGE" \
     "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
