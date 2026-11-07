THEOS_PACKAGE_SCHEME ?= rootless
export THEOS ?= $(HOME)/theos

TARGET = iphone:clang:latest:16.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CopyLogFix18
CopyLogFix18_FILES = CopyLogFix18.m
CopyLogFix18_FRAMEWORKS = Foundation
CopyLogFix18_CFLAGS = -fno-objc-arc -Wall -Wextra -Wno-unused-parameter
CopyLogFix18_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 pasted || true"
