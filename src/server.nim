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
  var server = wl_display_create();
  var backend = wlr_backend_autocreate(server);
  var renderer = wlr_renderer_autocreate(backend);
  var allocator = wlr_allocator_autocreate(backend, renderer);
  var scene = wlr_scene_create();
  var output_layout = wlr_output_layout_create();
  var xdg_shell = wlr_xdg_shell_create(server);
  var seat = wlr_seat_create(server, "herbwm-seat0");
  var cursor = wlr_cursor_create();
  var cursor_manager = wlr_xcursor_manager_create(nil, 24);
  var socket = wl_display_add_socket_auto(server);

  # If we cannot initialize the server with the renderer then quit.
  if not wlr_renderer_init_wl_display(renderer, server): quit(1)
  # TODO: I'm blindly discarding this for now, find out what the bool return means.
  discard wlr_scene_attach_output_layout(scene, output_layout);

  var compositor = wlr_compositor_create(server, renderer);
  var data_device_manager = wlr_data_device_manager_create(server);

  # Return the data.
  return HerbServer(
    server: server,
    backend: backend,
    renderer: renderer,
    allocator: allocator,
    scene: scene,
    socket: socket,
    new_output: wl_listener(
                  notify: proc (listener:ptr wl_listener, data:pointer){.cdecl.} =
                  var herb_server = fieldParentPtr(HerbServer,new_output, listener);
                  echo cast[int](herb_server)
                  var wlr_output = cast[wlr_output](data);
                  if (not wlr_output_init_render(addr(wlr_output), herb_server.allocator, herb_server.renderer)): 
                    return;
                ),
    output_layout: output_layout,
    xdg_shell: xdg_shell,
    seat: seat,
    cursor: cursor,
    cursor_manager: cursor_manager,
    compositor: compositor,
    data_device_manager: data_device_manager,
  )

# Function to deinitialize the server.
proc deinit_server(server: ptr HerbServer):void = 
  # Destroy the backend.
  wlr_backend_destroy(server.backend);
  # Destroy all clients spawned by the display.
  wl_display_destroy_clients(server.server);
  # Destroy the display / server.
  wl_display_destroy(server.server);
  quit(1);
