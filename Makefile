BINARY := herb
RELEASEFLAGS := -d:release
TARGET_DIR := /usr/bin

WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

all: dev

dev: xdg-shell-protocol.h
	@nimble build --verbose --passL:"-lwayland-server" --passL:"-lwlroots" --passL:"-lpixman-1" --maxLoopIterationsVM=99999999 --showAllMismatches:on

release: xdg-shell-protocol.h
	@nimble build $(RELEASEFLAGS) --verbose --passL:"-lwayland-server" --passL:"-lwlroots" --passL:"-lpixman-1" --maxLoopIterationsVM=99999999 --showAllMismatches:on

install: xdg-shell-protocol.h
	@mkdir -p $(TARGET_DIR)
	@cp $(BINARY) $(TARGET_DIR)
	@chmod +x $(TARGET_DIR)/$(BINARY)
	@cp ./assets/herb.desktop /usr/share/wayland-sessions/

uninstall:
	@rm -f $(TARGET_DIR)/$(BINARY)
	@rm -f /usr/share/wayland-sessions/$(BINRAY).desktop

clean:
	@rm -f ./herb xdg-shell-protocol.h

xdg-shell-protocol.h:
	@mkdir -p protocols
	@$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml "./protocols/xdg-shell-protocol.h"

.PHONY: check all install release run dev
