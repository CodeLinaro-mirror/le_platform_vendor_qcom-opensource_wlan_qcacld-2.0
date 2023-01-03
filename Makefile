KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build

M ?= $(shell pwd)

ifeq ($(WLAN_ROOT),)
# WLAN_ROOT must contain an absolute path (i.e. not a relative path)
KBUILD_OPTIONS := WLAN_ROOT=$(shell cd $(KERNEL_SRC); readlink -e $(M))
endif
#KBUILD_OPTIONS := WLAN_ROOT=$(PWD)
KBUILD_OPTIONS += MODNAME?=wlan
#ccflags-y += -wno-error -Wno-enum-conversion -Wno-error=enum-conversion
# Determine if the driver license is Open source or proprietary
# This is determined under the assumption that LICENSE doesn't change.
# Please change here if driver license text changes.
#LICENSE_FILE ?= $(PWD)/$(WLAN_ROOT)/CORE/HDD/src/wlan_hdd_main.c
LICENSE_FILE ?= $(WLAN_ROOT)/CORE/HDD/src/wlan_hdd_main.c
WLAN_OPEN_SOURCE = $(shell if grep -q "MODULE_LICENSE(\"Dual BSD/GPL\")" \
		$(LICENSE_FILE); then echo 1; else echo 0; fi)

#By default build for CLD
WLAN_SELECT := CONFIG_QCA_CLD_WLAN=m
KBUILD_OPTIONS += CONFIG_QCA_WIFI_ISOC=0
KBUILD_OPTIONS += CONFIG_QCA_WIFI_2_0=1
KBUILD_OPTIONS += $(WLAN_SELECT)
KBUILD_OPTIONS += WLAN_OPEN_SOURCE=$(WLAN_OPEN_SOURCE)
KBUILD_OPTIONS += $(KBUILD_EXTRA) # Extra config if any

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(shell pwd) modules $(KBUILD_OPTIONS)

modules_install:
	$(MAKE) INSTALL_MOD_STRIP=1 -C $(KERNEL_SRC) M=$(shell pwd) modules_install

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean $(KBUILD_OPTIONS)
