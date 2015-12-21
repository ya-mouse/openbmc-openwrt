#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libjpeg8
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=libjpeg-turbo-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://sourceforge.net/projects/libjpeg-turbo/files/$(PKG_VERSION)
PKG_MD5SUM:=e1e65cc711a1ade1322c06ad4a647741
PKG_BUILD_DIR:=$(BUILD_DIR)/libjpeg-turbo-$(PKG_VERSION)

PKG_LICENSE:=GPL-3
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex.ru>

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-jpeg8

CONFIGURE_VARS += \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes

TARGET_CFLAGS += $(FPIC)

define Package/libjpeg8
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=IJG JPEG compliant runtime library
  URL:=http://libjpeg-turbo.virtualgl.org/
endef

define Package/libjpeg8/description
 Runtime library supporting the Independent JPEG Group's standard
 for JPEG files.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libturbojpeg.a $(1)/usr/lib/
endef

define Package/libjpeg8/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjpeg.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libjpeg8))
