SQUASHFS4_HOST_VERSION:=4.3
SQUASHFS4_HOST_SOURCE:=squashfs$(SQUASHFS4_HOST_VERSION).tar.gz
SQUASHFS4_HOST_SOURCE_MD5:=d92ab59aabf5173f2a59089531e30dbf
SQUASHFS4_HOST_SITE:=@SF/squashfs

# Enable legacy SquashFS formats support (SquashFS-1/2/3, ZLIB/LZMA1 compressed)
# 1 - to enable
# 0 - to disable
SQUASHFS4_ENABLE_LEGACY_FORMATS_SUPPORT:=0

SQUASHFS4_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs4-host
SQUASHFS4_HOST_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS4_HOST_VERSION)
SQUASHFS4_HOST_BUILD_DIR:=$(SQUASHFS4_HOST_DIR)/squashfs-tools

SQUASHFS4_HOST_TOOLS:=mksquashfs unsquashfs
SQUASHFS4_HOST_TOOLS_BUILD_DIR:=$(addprefix $(SQUASHFS4_HOST_BUILD_DIR)/,$(SQUASHFS4_HOST_TOOLS))
SQUASHFS4_HOST_TOOLS_TARGET_DIR:=$(SQUASHFS4_HOST_TOOLS:%=$(TOOLS_DIR)/%4-lzma-avm-be)

squashfs4-host-source: $(DL_DIR)/$(SQUASHFS4_HOST_SOURCE)
$(DL_DIR)/$(SQUASHFS4_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS4_HOST_SOURCE) $(SQUASHFS4_HOST_SITE) $(SQUASHFS4_HOST_SOURCE_MD5)

squashfs4-host-unpacked: $(SQUASHFS4_HOST_DIR)/.unpacked
$(SQUASHFS4_HOST_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS4_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS4_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SQUASHFS4_HOST_MAKE_DIR)/patches,$(SQUASHFS4_HOST_DIR))
	touch $@

$(SQUASHFS4_HOST_TOOLS_BUILD_DIR): $(SQUASHFS4_HOST_DIR)/.unpacked $(LZMA2_HOST_DIR)/liblzma.a
	$(MAKE) -C $(SQUASHFS4_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		EXTRA_CFLAGS="-DTARGET_FORMAT=AVM_BE" \
		LEGACY_FORMATS_SUPPORT=$(SQUASHFS4_ENABLE_LEGACY_FORMATS_SUPPORT) \
		GZIP_SUPPORT=$(SQUASHFS4_ENABLE_LEGACY_FORMATS_SUPPORT) \
		LZMA_XZ_SUPPORT=$(SQUASHFS4_ENABLE_LEGACY_FORMATS_SUPPORT) \
		XZ_SUPPORT=1 \
		XZ_DIR="$(abspath $(LZMA2_HOST_DIR))" \
		COMP_DEFAULT=xz \
		XATTR_SUPPORT=0 \
		XATTR_DEFAULT=0 \
		$(SQUASHFS4_HOST_TOOLS)
	touch -c $@

$(SQUASHFS4_HOST_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%4-lzma-avm-be: $(SQUASHFS4_HOST_BUILD_DIR)/%
	$(INSTALL_FILE)
	strip $@

squashfs4-host: $(SQUASHFS4_HOST_TOOLS_TARGET_DIR)

squashfs4-host-clean:
	-$(MAKE) -C $(SQUASHFS4_HOST_BUILD_DIR) clean

squashfs4-host-dirclean:
	$(RM) -r $(SQUASHFS4_HOST_DIR)

squashfs4-host-distclean: squashfs4-host-dirclean
	$(RM) $(SQUASHFS4_HOST_TOOLS_TARGET_DIR)
