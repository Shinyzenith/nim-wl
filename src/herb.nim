import futhark
importc:
  sysPath "/usr/lib/clang/13.0.1/include"
  path "../protocols"
  compilerArg "-DWLR_USE_UNSTABLE"
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

#TODO: Use OOP to clean this up, currently this is just a POC stage.

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

# Creating a callback for when we recieve a new_output event from the server backend.
proc new_output_callback(listener:ptr structwllistener_18485576, data:pointer){.cdecl.} =
  echo "New output detected"
  # Casting the data to a wlr_output object for later user to initialize the renderer.
  var wlr_output: structwlroutput_18485660 = cast[structwlroutput_18485660](data);
  # This will work once I switch to OOP model.
  # discard wlr_output_init_render(addr(wlr_output), allocator, renderer)

# Create the listener (wl_listener) with our callback assigned to it's notify field.
var new_output =  structwllistener_18485576(notify: new_output_callback);

# Adding our wl_listener object to the list of callbacks to fire on new_output event.
wl_list_insert(backend.events.new_output.listener_list.prev, addr(new_output.link));

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
