#!/bin/bash

# fix gcc14
if [ "$GCC_VERSION" = "GCC14" ] || [ "$GCC_VERSION" = "GCC15" ]; then
    # linux-atm
    rm -rf package/network/utils/linux-atm
    git clone https://$github/sbwml/package_network_utils_linux-atm package/network/utils/linux-atm
fi

# fix gcc-15
if [ "$USE_GCC15" = y ]; then
    sed -i '/TARGET_CFLAGS/ s/$/ -Wno-error=unterminated-string-initialization/' package/libs/mbedtls/Makefile
    # elfutils
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/elfutils/901-backends-fix-string-initialization-error-on-gcc15.patch > package/libs/elfutils/patches/901-backends-fix-string-initialization-error-on-gcc15.patch
    # libwebsockets
    mkdir -p feeds/packages/libs/libwebsockets/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/libwebsockets/901-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libwebsockets/patches/901-fix-string-initialization-error-on-gcc15.patch
    # libxcrypt
    mkdir -p feeds/packages/libs/libxcrypt/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15/libxcrypt/901-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libxcrypt/patches/901-fix-string-initialization-error-on-gcc15.patch
fi

# fix gcc-15.0.1 C23
if [ "$GCC_VERSION" = "GCC15" ]; then
    # gmp
    mkdir -p package/libs/gmp/patches
    curl -s $mirror/openwrt/patch/openwrt-6.x/gcc-15-c23/gmp/001-fix-build-with-gcc-15.patch > package/libs/gmp/patches/001-fix-build-with-gcc-15.patch
    # htop - 24.10-NEXT
    HTOP_VERSION=3.4.1
    HTOP_HASH=af9ec878f831b7c27d33e775c668ec79d569aa781861c995a0fbadc1bdb666cf
    sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$HTOP_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$HTOP_HASH/" feeds/packages/admin/htop/Makefile
    # libtirpc
    sed -i '/TARGET_CFLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libtirpc/Makefile
    # libsepol
    sed -i '/HOST_MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libsepol/Makefile
    # tree
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/tree/Makefile
    # gdbm
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/gdbm/Makefile
    # libical
    sed -i '/CMAKE_OPTIONS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libical/Makefile
    # libconfig
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/feeds/packages/libconfig/Makefile
    # lsof
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/lsof/Makefile
    # screen
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/screen/Makefile
    # ppp
    sed -i '/CONFIGURE_VARS/i \\nTARGET_CFLAGS += -std=gnu17\n' package/network/services/ppp/Makefile
    # vim
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/vim/Makefile
    # mtd
    sed -i '/target=/i TARGET_CFLAGS += -std=gnu17\n' package/system/mtd/Makefile
    # libselinux
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libselinux/Makefile
    # avahi
    sed -i '/TARGET_CFLAGS +=/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/avahi/Makefile
    # bash
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bash/Makefile
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile
    # dnsmasq
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/network/services/dnsmasq/Makefile
    # bluez
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bluez/Makefile
    # e2fsprogs
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/e2fsprogs/Makefile
    # f2fs-tools
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/f2fs-tools/Makefile
    # krb5
    sed -i '/CONFIGURE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/krb5/Makefile
    # parted
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/parted/Makefile
    # iperf3
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/iperf3/Makefile
    # db
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/db/Makefile
    # python3
    sed -i '/TARGET_CONFIGURE_OPTS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/python/python3/Makefile
    # uwsgi
    sed -i '/MAKE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/uwsgi/Makefile
    # perl
    sed -i '/Target perl/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/perl/Makefile
    # rsync
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/rsync/Makefile
    # shine
    sed -i '/Build\/InstallDev/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/sound/shine/Makefile
    # jq
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/jq/Makefile
    # coova-chilli
    sed -i '/TARGET_CFLAGS/s/$/ -std=gnu17/' feeds/packages/net/coova-chilli/Makefile
    # rtl8812au-ct
    sed -i '/^NOSTDINC_FLAGS/ s/$/ -std=gnu17/' package/kernel/rtl8812au-ct/Makefile
fi
