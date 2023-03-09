DGPRESCUE_VERSION = 0.1
DGPRESCUE_SITE = $(BR2_EXTERNAL_DGPRESCUE_PATH)/package/dgprescue
DGPRESCUE_SITE_METHOD = local

DGPRESCUE_STATIC_ETH_INTERFACE = $(call qstrip,$(BR2_PACKAGE_DGPRESCUE_STATIC_ETH_INTERFACE))
DGPRESCUE_STATIC_ETH_ADDR = $(call qstrip,$(BR2_PACKAGE_DGPRESCUE_STATIC_ETH_ADDRV4))

ifneq ($(DGPRESCUE_STATIC_ETH_INTERFACE),)
define DGPRESCUE_STATIC_ETH_CONFIG
	ADDR=`echo $(DGPRESCUE_STATIC_ETH_ADDR) | cut -d "/" -f 1`; \
	CIDR=`echo $(DGPRESCUE_STATIC_ETH_ADDR) | cut -d "/" -f 2`; \
	NETMASK=$$(( 0xffffffff ^ ((1 << (32 - $$CIDR)) - 1) )); \
    	NETMASKSTR=$$(( ($$NETMASK >> 24) & 0xff ))"."$$(( ($$NETMASK >> 16) & 0xff ))"."$$(( ($$NETMASK >> 8) & 0xff ))"."$$(( $NETMASK & 0xff )); \
	( \
		echo ; \
		echo "#dgprescue-static-start"; \
		echo "auto $(DGPRESCUE_STATIC_ETH_INTERFACE)"; \
		echo "iface $(DGPRESCUE_STATIC_ETH_INTERFACE) inet static"; \
		echo "  wait-delay 15"; \
		echo "  address $$ADDR"; \
		echo "#/$$CIDR"; \
		echo "  netmask $$NETMASKSTR"; \
		echo "#dgprescue-static-end"; \
	) >> $(@D)/rescue-interfaces
endef
endif # static eth

#DGPRESCUE_TARGET_FINALIZE_HOOKS += DGPRESCUE_STATIC_ETH_CONFIG

# eth install
ifeq ($(BR2_PACKAGE_DGPRESCUE_HAVE_ETH_RESCUE),y)
define DGPRESCUE_INSTALL_INIT_SYSV_ETH
	$(INSTALL) -m 0755 -D $(@D)/S99dgprescue_eth $(TARGET_DIR)/etc/init.d/S99dgprescue_eth
	mkdir -p $(TARGET_DIR)/etc/dgprescue/
	touch $(@D)/rescue-interfaces
	$(DGPRESCUE_STATIC_ETH_CONFIG)
	cp $(@D)/rescue-interfaces $(TARGET_DIR)/etc/dgprescue/interfaces
endef
endif

# mtp install
ifeq ($(BR2_PACKAGE_DGPRESCUE_HAVE_MTP_RESCUE),y)
define DGPRESCUE_INSTALL_INIT_SYSV_MTP
	$(INSTALL) -m 0755 -D $(@D)/S99dgprescue_mtp $(TARGET_DIR)/etc/init.d/S99dgprescue_mtp
endef

define DGPRESCUE_INSTALL_TARGET_CMDS_MTP
	 $(INSTALL) -m 0755 -D $(@D)/dgprescue_mtp_fw.sh $(TARGET_DIR)/usr/sbin/dgprescue_mtp_fw.sh
	 $(INSTALL) -m 0755 -D $(@D)/dgprescue_mtp_cmd.sh $(TARGET_DIR)/usr/sbin/dgprescue_mtp_cmd.sh
endef
endif

define DGPRESCUE_INSTALL_INIT_SYSV
	$(DGPRESCUE_INSTALL_INIT_SYSV_ETH)
	$(DGPRESCUE_INSTALL_INIT_SYSV_MTP)
endef

define DGPRESCUE_INSTALL_TARGET_CMDS
	$(DGPRESCUE_INSTALL_TARGET_CMDS_MTP)
endef

$(eval $(generic-package))
