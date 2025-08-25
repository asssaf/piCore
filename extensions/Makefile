OUTPUT_DIR := ../build
SUBDIRS = service-serial service-wifi service-dhcp service-dhcpd service-hostapd recovery

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ OUTPUT_DIR=$(OUTPUT_DIR)

.PHONY: $(SUBDIRS)
