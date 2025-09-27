OUTPUT_DIR := ../build
SUBDIRS = service-serial service-wifi service-dhcp service-dhcpd service-hostapd recovery service-gadget firewall service-watchdog

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ OUTPUT_DIR=$(OUTPUT_DIR)

.PHONY: $(SUBDIRS)
