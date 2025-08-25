OUTPUT_DIR := build
EXTDIR := extension
TCZ := $(OUTPUT_DIR)/$(shell basename $(CURDIR)).tcz
LIST := $(TCZ).list
MD5 := $(TCZ).md5.txt

all: $(LIST) $(MD5)


$(TCZ): $(EXTDIR)
	mkdir -p $(OUTPUT_DIR)
	mksquashfs $(EXTDIR) $(TCZ) -all-root -noappend


$(LIST): $(TCZ)
	unsquashfs -lc $(TCZ) | sed 's|^squashfs-root/||' > $(LIST)


$(MD5): $(TCZ)
	md5sum $(TCZ) > $(MD5)


clean:
	rm -r $(TCZ) $(LIST) $(MD5)
