$(call PKG_INIT_BIN, 2.6.16-060323)
$(PKG)_SOURCE:=iproute2-$($(PKG)_VERSION).tar.gz
#$(PKG)_DIR:=iproute2-$($(PKG)_VERSION)/$($(PKG)_DIR)/tc
#$(PKG)_SITE:=http://devresources.linux-foundation.org/dev/iproute2/download/ - currently down :(
$(PKG)_SITE:=http://www.jzab.de/files/iproute2/
$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/tc/tc.c
$(PKG)_BINARY:=$($(PKG)_DIR)/tc/tc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/tc

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="mipsel" \
		-C $(IPROUTE2_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IPROUTE2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(IPROUTE2_TARGET_BINARY)

$(PKG_FINISH)
