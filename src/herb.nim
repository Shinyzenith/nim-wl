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

wlr_log_init(Wlrdebug,nil)

var server = try: wl_display_create()
              except: quit(1)

var backend = try: wlr_backend_autocreate(server)
                except: quit(1)

var renderer = try: wlr_renderer_autocreate(backend)
                except: quit(1)

var allocator = try: wlr_allocator_autocreate(backend, renderer)
                  except: quit(1)

var scene = try: wlr_scene_create()
              except: quit(1)

var xdg_shell = try: wlr_xdg_shell_create(server)
              except: quit(1)

var seat = try: wlr_seat_create(server, "nimwl-seat0")
            except: quit(1)

var cursor = try: wlr_cursor_create()
                except: quit(1)

var cursor_manager = try: wlr_xcursor_manager_create(nil, 24)
                      except: quit(1)

if not wlr_renderer_init_wl_display(renderer, server):
  quit(1)

discard wlr_compositor_create(server, renderer)

discard wlr_data_device_manager_create(server)

var socket = try: wl_display_add_socket_auto(server)
              except: quit(1)

if not wlr_backend_start(backend):
  wlr_backend_destroy(backend)
  wl_display_destroy(server)

wl_display_run(server)
wl_display_destroy_clients(server)
wl_display_destroy(server)
