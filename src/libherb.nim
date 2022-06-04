import futhark
importc:
  sysPath "/usr/lib/clang/13.0.1/include"
  compilerArg "-DWLR_USE_UNSTABLE"
  path "../protocols"
  path "/usr/include/pixman-1"
  path "/usr/include/wayland"
  path "/usr/include/libxkbcommon"
  "time.h"
  "wayland-server-core.h"
  "wayland-server-protocol.h"
  "wayland-server.h"
  "wayland-util.h"
  "wlr/backend.h"
  "wlr/render/allocator.h"
  "wlr/render/wlr_renderer.h"
  "wlr/types/wlr_compositor.h"
  "wlr/types/wlr_cursor.h"
  "wlr/types/wlr_data_device.h"
  "wlr/types/wlr_output.h"
  "wlr/types/wlr_output_layout.h"
  "wlr/types/wlr_scene.h"
  "wlr/types/wlr_scene.h"
  "wlr/types/wlr_seat.h"
  "wlr/types/wlr_xcursor_manager.h"
  "wlr/types/wlr_xdg_shell.h"
  "wlr/util/log.h"

type
  wl_display* = structwldisplay
  wl_listener* = structwllistener
  wl_signal* = structwlsignal
  wlr_allocator* = structwlrallocator
  wlr_backend* = structwlrbackend
  wlr_compositor* = structwlrcompositor
  wlr_cursor* = structwlrcursor
  wlr_data_device_manager* = structwlrdatadevicemanager
  wlr_output* = structwlroutput
  wlr_output_layout* = structwlroutputlayout
  wlr_renderer* = structwlrrenderer
  wlr_scene* = structwlrscene
  wlr_seat* = structwlrseat
  wlr_xcursor_manager* = structwlrxcursormanager
  wlr_xdg_shell* = structwlrxdgshell
  wlr_xdg_surface* = structwlrxdgsurface

proc wl_signal_add*(wl_signal: wl_signal, wl_listener: var wl_listener) =
  wl_list_insert(wl_signal.listener_list.prev, unsafeAddr(wl_listener.link));

template fieldParentPtr*(T: typedesc, field: untyped, data: pointer): auto =
  cast[ptr T](cast[int](data) - offsetOf(T, field))[]

type
  HerbServer* = object
    server*: ptr wl_display
    backend*: ptr wlr_backend
    renderer*: ptr wlr_renderer
    allocator*: ptr wlr_allocator
    scene*: ptr wlr_scene

    socket*: cstring

    new_output*: wl_listener

    output_layout*: ptr wlr_output_layout

    xdg_shell*: ptr wlr_xdg_shell
    new_surface*: wl_listener

    seat*: ptr wlr_seat

    cursor*: ptr wlr_cursor
    cursor_manager*: ptr wlr_xcursor_manager

    compositor*: ptr wlr_compositor
    data_device_manager*: ptr wlr_data_device_manager

type
  HerbOutput* = object
    server*: ptr HerbServer
    output*: ptr wlr_output
    new_frame*: wl_listener

proc init_server*(): HerbServer =
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
    notify: proc (listener: ptr wl_listener, data: pointer){.cdecl.} =
    echo "New Output Detected"
    var herb_server = fieldParentPtr(HerbServer, new_output, listener);
    var wlr_output = cast[ptr wlr_output](data);
    discard wlr_output_init_render(wlr_output, herb_server.allocator,
        herb_server.renderer);

    if wl_list_empty(addr(wlr_output.modes)) == 0:
      wlr_output_set_mode(wlr_output, wlr_output_preferred_mode(wlr_output))
      wlr_output_enable(wlr_output, true);
      if not wlr_output_commit(wlr_output):
        return

    var herb_output = create(HerbOutput);
    herb_output.server = addr(herb_server);
    herb_output.output = wlr_output;
    herb_output.new_frame = wl_listener(
      notify: proc(listener: ptr wl_listener, data: pointer){.cdecl.} =
      echo "New Frame Detected";
      dealloc(fieldParentPtr(HerbOutput, newFrame, listener).addr);
      var output = fieldParentPtr(HerbOutput, new_frame, listener);
      var scene_output = wlr_scene_get_scene_output(output.server.scene,
          output.output);
      discard wlr_scene_output_commit(scene_output);
      var time: structtimespec;
      discard clock_gettime(Clockmonotonic, addr(time));
      wlr_scene_output_send_frame_done(scene_output, addr(time));
    )
    wl_signal_add(wlr_output.events.frame, herb_output.new_frame);
    wlr_output_layout_add_auto(herb_server.output_layout, wlr_output);
  )

  result.new_surface = wl_listener(
    notify: proc (listener: ptr wl_listener, data: pointer){.cdecl.} =
    echo "New Surface Detected"
    var herb_server = fieldParentPtr(HerbServer, new_surface, listener);
    var wlr_xdg_surface = cast[ptr wlr_xdg_surface](data);
    echo wlr_xdg_surface.role;
  )

  wl_signal_add(result.backend.events.new_output, result.new_output);
  wl_signal_add(result.xdg_shell.events.new_surface, result.new_surface);

  if not wlr_renderer_init_wl_display(result.renderer, result.server): quit(1)
  discard wlr_scene_attach_output_layout(result.scene, result.output_layout);

proc deinit_server*(server: ptr HerbServer): void =
  wlr_backend_destroy(server.backend);
  wl_display_destroy_clients(server.server);
  wl_display_destroy(server.server);
  quit(1);
