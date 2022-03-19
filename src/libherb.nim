import futhark
importc:
  sysPath "/usr/lib/clang/13.0.1/include"
  compilerArg "-DWLR_USE_UNSTABLE"
  path "../protocols"
  "wayland-server-core.h" 
  "wayland-server-protocol.h"
  "wayland-server.h"
  "wayland-util.h"
  "wlr/backend.h"
  "wlr/render/allocator.h"
  "wlr/render/wlr_renderer.h"
  "wlr/types/wlr_compositor.h"
  "wlr/types/wlr_compositor.h"
  "wlr/types/wlr_cursor.h"
  "wlr/types/wlr_data_device.h"
  "wlr/types/wlr_output.h"
  "wlr/types/wlr_scene.h"
  "wlr/types/wlr_seat.h"
  "wlr/types/wlr_xcursor_manager.h"
  "wlr/types/wlr_xdg_shell.h"
  "wlr/util/log.h"

# Re-defining a few type names because the ones from futhark are terrible.
type
  wlr_output* = structwllistener_18485576
  wl_listener* = structwllistener_18485576
  wl_signal* = structwlsignal_18485891

# Re-defining a inline functions because opir currently does not parse inline functions.
proc wl_signal_add(wl_signal: wl_signal, wl_listener: wl_listener) =
  wl_list_insert(wl_signal.listener_list.prev, unsafeAddr(wl_listener.link));
