BINARY := herb
BUILDFLAGS := -d:release
TARGET_DIR := /usr/bin
SOURCE_DIR := ./$(BINARY)

WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

all: build

build: xdg-shell-protocol.h
	@sudo cp ./xdg-shell-protocol.h /usr/include/wlr/types 
	@nimble build $(BUILDFLAGS) --verbose --passL:"-lwayland-server" --passL:"-lwlroots" 
	@sudo rm /usr/include/wlr/types/xdg-shell-protocol.h 
	# !! we use sudo to manually copy over the headers, this is a terrible approach!! talk to the dev of futhark asap.

install: xdg-shell-protocol.h
	@mkdir -p $(TARGET_DIR)
	@cp $(SOURCE_DIR)/$(BINARY) $(TARGET_DIR)
	@chmod +x $(TARGET_DIR)/$(BINARY)

uninstall:
	@rm $(TARGET_DIR)/$(BINARY)

clean:
	@rm ./herb tinywl xdg-shell-protocol.h

xdg-shell-protocol.h:
	@$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

.PHONY: check all install build run
