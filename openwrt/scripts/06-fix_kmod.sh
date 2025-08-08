#!/bin/bash -e

# clang
if [ "$KERNEL_CLANG_LTO" = "y" ]; then
    # xtables-addons module
    rm -rf feeds/packages/net/xtables-addons
    git clone https://$github/sbwml/kmod_packages_net_xtables-addons feeds/packages/net/xtables-addons
    # netatop
    sed -i 's/$(MAKE)/$(KERNEL_MAKE)/g' feeds/packages/admin/netatop/Makefile
    curl -s $mirror/openwrt/patch/packages-patches/clang/netatop/900-fix-build-with-clang.patch > feeds/packages/admin/netatop/patches/900-fix-build-with-clang.patch
    # dmx_usb_module
    rm -rf feeds/packages/libs/dmx_usb_module
    git clone https://$gitea/sbwml/feeds_packages_libs_dmx_usb_module feeds/packages/libs/dmx_usb_module
    # macremapper
    curl -s $mirror/openwrt/patch/packages-patches/clang/macremapper/100-macremapper-fix-clang-build.patch | patch -p1
    # coova-chilli module
    rm -rf feeds/packages/net/coova-chilli
    git clone https://$github/sbwml/kmod_packages_net_coova-chilli feeds/packages/net/coova-chilli
else
    # coova-chilli - fix gcc 15 c23
    [ "$USE_GCC15" = y ] && sed -i '/TARGET_CFLAGS/s/$/ -std=gnu17/' feeds/packages/net/coova-chilli/Makefile
fi
