OUTPUT_DIR := ../build
SUBDIRS = service-serial service-wifi service-dhcp

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ OUTPUT_DIR=$(OUTPUT_DIR)

.PHONY: $(SUBDIRS)
