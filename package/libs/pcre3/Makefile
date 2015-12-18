#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcre
PKG_VERSION:=8.35
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://sourceforge.net/projects/pcre/files/pcre/$(PKG_VERSION)
PKG_MD5SUM:=6aacb23986adccd9b3bc626c00979958

PKG_LICENSE:=GPL-3
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Felix Fietkau <nbd@openwrt.org>

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

define Package/pcre3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=PERL 5 regular expression pattern matching
  DEPENDS:=+libstdcpp
  URL:=http://www.pcre.org/
endef

define Package/pcre3/description
 This is a library of functions to support regular expressions whose syntax 
 and semantics are as close as possible to those of the Perl 5 language.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre*.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpcre.pc $(1)/usr/lib/pkgconfig/
endef

define Package/pcre3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,pcre3))
