#!/bin/bash -e

# 使用特定的优化
sed -i 's,-mcpu=generic,-march=armv8-a+crc+crypto,g' include/target.mk
sed -i 's,kmod-r8168,kmod-r8169,g' target/linux/rockchip/image/armv8.mk
