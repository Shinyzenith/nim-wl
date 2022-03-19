include libherb

# Defining our server object.
type
  HerbServer* = object
    server: ptr wl_display
    backend: ptr wlr_backend
    renderer: ptr wlr_renderer
    allocator: ptr wlr_allocator
    scene: ptr wlr_scene

    socket: cstring

    new_output: wl_listener

    output_layout: ptr wlr_output_layout

    xdg_shell: ptr wlr_xdg_shell

    seat: ptr wlr_seat

    cursor: ptr wlr_cursor
    cursor_manager: ptr wlr_xcursor_manager

    compositor: ptr wlr_compositor
    data_device_manager: ptr wlr_data_device_manager


# Function to create the server.
proc init_server():HerbServer = 
  result.server = wl_display_create();
  result.backend = wlr_backend_autocreate(result.server);
  result.renderer = wlr_renderer_autocreate(result.backend);
  result.allocator = wlr_allocator_autocreate(result.backend, result.renderer);
  result.scene = wlr_scene_create();
  result.output_layout = wlr_output_layout_create();
  result.xdg_shell = wlr_xdg_shell_create(result.server);
  result.seat = wlr_seat_create(result.server, "herbwm-seat0");
  result.cursor = wlr_cursor_create();
  result.cursor_manager = wlr_xcursor_manager_create(nil, 24);
  result.socket = wl_display_add_socket_auto(result.server);
  result.compositor = wlr_compositor_create(result.server, result.renderer);
  result.data_device_manager = wlr_data_device_manager_create(result.server);
  result.new_output = wl_listener(
    notify: proc (listener:ptr wl_listener, data:pointer){.cdecl.} =
    var herb_server = fieldParentPtr(HerbServer,new_output, listener);
    echo "New output detected.";
    var wlr_output = cast[ptr wlr_output](data);
    if (not wlr_output_init_render(wlr_output, herb_server.allocator, herb_server.renderer)): 
      return;
  )
  # If we cannot initialize the server with the renderer then quit.
  if not wlr_renderer_init_wl_display(result.renderer, result.server): quit(1)

  # TODO: I'm blindly discarding this for now, find out what the bool return means.
  discard wlr_scene_attach_output_layout(result.scene, result.output_layout);



# Function to deinitialize the server.
proc deinit_server(server: ptr HerbServer):void = 
  # Destroy the backend.
  wlr_backend_destroy(server.backend);
  # Destroy all clients spawned by the display.
  wl_display_destroy_clients(server.server);
  # Destroy the display / server.
  wl_display_destroy(server.server);
  quit(1);
