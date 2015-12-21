#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pixman
PKG_VERSION:=0.32.6
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://cairographics.org/releases/
PKG_MD5SUM:=3a30859719a41bd0f5cccffbfefdd4c2

PKG_LICENSE:=GPL-3
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex.ru>

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-gtk \
	--enable-shared \
	--enable-static \
	--disable-silent-rules \
	--disable-arm-simd \
	--disable-arm-neon \
	--disable-arm-iwmmxt \
	--disable-arm-iwmmxt2

CONFIGURE_VARS += \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes

TARGET_CFLAGS += $(FPIC)

define Package/pixman
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=pixel-manipulation library for X and cairo
  URL:=http://cairographics.org/
endef

define Package/pixman/description
 A library for manipulating pixel regions -- a set of Y-X banded
 rectangles, image compositing using the Porter/Duff model
 and implicit mask generation for geometric primitives including
 trapezoids, triangles, and rectangles.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/pixman-1
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pixman-1/*.h $(1)/usr/include/pixman-1/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpixman*.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/pixman-1.pc $(1)/usr/lib/pkgconfig/
endef

define Package/pixman/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpixman*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,pixman))
