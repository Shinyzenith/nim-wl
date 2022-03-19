import libherb
include server

wlr_log_init(Wlrdebug,nil);

# Setting up basic needs for the server.
var server = init_server();

# If we cannot initialize the server with the renderer then quit.
if not wlr_renderer_init_wl_display(server.renderer, server.server): quit(1)

# Creating a callback for when the new_output event is fired by the backend.
var new_output =  wl_listener(
  notify: proc (listener:ptr wlr_output, data:pointer){.cdecl.} =
    echo "New output detected"
    var wlr_output: wlr_output = cast[wlr_output](data);
  );

# Assigning our callback to the new_output event fired by the backend when a new monitor / output is plugged in.
wl_signal_add(server.backend.events.new_output, new_output);

# Instantiate the WAYLAND_SOCKET.
var socket = wl_display_add_socket_auto(server.server);

# If we fail to start the backend then destrory the backend, the server and then quit.
if not wlr_backend_start(server.backend):
  wlr_backend_destroy(server.backend);
  wl_display_destroy(server.server);
  quit(1);

# Run the server, this function is blocking in nature.
wl_display_run(server.server);

# If we reach this line, it means that the compositor is no longer running,
# so we destroy all clients and it's displays.
wl_display_destroy_clients(server.server);
wl_display_destroy(server.server);
