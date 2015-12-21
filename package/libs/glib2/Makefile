#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=glib
PKG_VERSION:=2.46.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/2.46
PKG_MD5SUM:=7f815d6e46df68e070cb421ed7f1139e

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Anton D. Kachalov <mouse@yandex.ru>

include $(INCLUDE_DIR)/package.mk

define Package/libglib2
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libffi +pcre3 +zlib
  TITLE:=GLib libraries
endef

define Package/libglib2/description
	GLib is a library containing many useful C routines for things such
	 as trees, hashes, lists, and strings.  It is a useful general-purpose
	 C library used by projects such as GTK+, GIMP, and GNOME.
endef

# prevent "autoreconf" from removing "aclocal.m4"
PKG_REMOVE_FILES:=

CONFIGURE_ARGS += \
	--with-pcre=system \
	--disable-modular-tests \
	--disable-gtk-doc \
	--enable-shared \
	--enable-static \
	--enable-debug=minimum \
	--disable-selinux

CONFIGURE_VARS += \
	bash_cv_wcwidth_broken=no \
	bash_cv_func_sigsetjmp=yes \
	glib_cv_stack_grows=no \
	glib_cv_uscore=no

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/glib-2.0 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/glib-2.0/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.{a,so,so.*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/glib-2.0/include/*.h $(1)/usr/lib/glib-2.0/include/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/share/aclocal
	$(CP) $(PKG_INSTALL_DIR)/usr/share/aclocal/* $(1)/usr/share/aclocal/
endef

define Package/libglib2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.{so,so.*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libglib2))
