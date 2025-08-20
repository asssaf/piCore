OUTPUT_DIR := ../build
SUBDIRS = service-serial

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ OUTPUT_DIR=$(OUTPUT_DIR)

.PHONY: $(SUBDIRS)
