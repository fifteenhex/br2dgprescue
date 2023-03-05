DGPRESCUE_VERSION = 0.1
DGPRESCUE_SITE = $(BR2_EXTERNAL_DGPRESCUE_PATH)/package/dgprescue
DGPRESCUE_SITE_METHOD = local

define DGPRESCUE_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/S99dgprescue $(TARGET_DIR)/etc/init.d/S99dgprescue
endef

$(eval $(generic-package))
