import futhark
importc:
  sysPath "/usr/lib/clang/13.0.1/include"
  compilerArg "-DWLR_USE_UNSTABLE"
  "wayland-server.h"
  "wayland-server-core.h"
  "wayland-server-protocol.h"
  "wlr/backend.h"
  "wlr/render/allocator.h"
  "wlr/render/wlr_renderer.h"
  "wlr/types/wlr_compositor.h"
  "wlr/types/wlr_compositor.h"
  "wlr/types/wlr_cursor.h"
  "wlr/types/wlr_data_device.h"
  "wlr/types/wlr_scene.h"
  "wlr/types/wlr_seat.h"
  "wlr/types/wlr_xcursor_manager.h"
  "wlr/util/log.h"
  "wlr/types/wlr_xdg_shell.h"

# Setting up logging.
wlr_log_init(Wlrdebug,nil);

# Setting up basic needs for the server.
var server = wl_display_create();
var backend = wlr_backend_autocreate(server);
var renderer = wlr_renderer_autocreate(backend);
var allocator = wlr_allocator_autocreate(backend, renderer);
var scene = wlr_scene_create();
var xdg_shell = wlr_xdg_shell_create(server);
var seat = wlr_seat_create(server, "nimwl-seat0");
var cursor = wlr_cursor_create();
var cursor_manager = wlr_xcursor_manager_create(nil, 24);

# If we cannot initialize the server with the renderer then quit.
if not wlr_renderer_init_wl_display(renderer, server): quit(1)

# Create the compositor and the data_device_manager
discard wlr_compositor_create(server, renderer);
discard wlr_data_device_manager_create(server);

# Instantiate the WAYLAND_SOCKET.
var socket = wl_display_add_socket_auto(server);

# If we fail to start the backend then destrory the backend, the server and then quit.
if not wlr_backend_start(backend):
  wlr_backend_destroy(backend);
  wl_display_destroy(server);
  quit(1);

# Run the server, this function is blocking in nature.
wl_display_run(server);

# If we reach this line, it means that the compositor is no longer running,
# so we destroy all clients and it's displays.
wl_display_destroy_clients(server);
wl_display_destroy(server);
