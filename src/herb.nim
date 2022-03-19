include libherb

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

# Create the compositor and the data_device_manager and get rid of it's returned data.
discard wlr_compositor_create(server, renderer);
discard wlr_data_device_manager_create(server);

# Creating a callback for when the new_output event is fired by the backend.
var new_output =  wl_listener(
  notify: proc (listener:ptr wlr_output, data:pointer){.cdecl.} =
    echo "New output detected"
    var wlr_output: wlr_output = cast[wlr_output](data);
  );

# Assigning our callback to the new_output event fired by the backend when a new monitor / output is plugged in.
wl_signal_add(backend.events.new_output, new_output);

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
