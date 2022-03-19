import libherb
include server

wlr_log_init(Wlrdebug,nil);

# Setting up basic needs for the herb_server.
var herb_server = init_server();

echo cast[int](herb_server)
# Assigning our callback to the new_output event fired by the backend when a new monitor / output is plugged in.
wl_signal_add(
  herb_server.backend.events.new_output,
  herb_server.new_output
);

# If we fail to start the backend then destrory the backend, the server and then quit.
if not wlr_backend_start(herb_server.backend):
  deinit_server(addr(herb_server));

# Run the server, this function is blocking in nature.
wl_display_run(herb_server.server);

# If we reach this line, it means that the compositor is no longer running,
# so we destroy all clients and it's displays.
deinit_server(addr(herb_server));
