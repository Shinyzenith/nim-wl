BINARY := herb
BUILDFLAGS := -d:release
TARGET_DIR := /usr/bin
SOURCE_DIR := ./$(BINARY)

WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

all: build

build: xdg-shell-protocol.h
	@nimble build $(BUILDFLAGS) --verbose --passL:"-lwayland-server" --passL:"-lwlroots" --passL:"-lpixman-1" --maxLoopIterationsVM=99999999 --showAllMismatches:on

install: xdg-shell-protocol.h
	@mkdir -p $(TARGET_DIR)
	@cp $(SOURCE_DIR)/$(BINARY) $(TARGET_DIR)
	@chmod +x $(TARGET_DIR)/$(BINARY)

uninstall:
	@rm -f $(TARGET_DIR)/$(BINARY)

clean:
	@rm -f ./herb xdg-shell-protocol.h

xdg-shell-protocol.h:
	@mkdir -p protocols
	@$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml "./protocols/xdg-shell-protocol.h"

.PHONY: check all install build run
