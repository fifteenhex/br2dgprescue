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

define DGPRESCUE_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/S99dgprescue $(TARGET_DIR)/etc/init.d/S99dgprescue
	mkdir -p $(TARGET_DIR)/etc/dgprescue/
	touch $(@D)/rescue-interfaces
	$(DGPRESCUE_STATIC_ETH_CONFIG)
	cp $(@D)/rescue-interfaces $(TARGET_DIR)/etc/dgprescue/interfaces
endef

$(eval $(generic-package))
