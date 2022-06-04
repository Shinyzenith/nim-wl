import libherb
wlr_log_init(Wlrdebug,nil);

var herb_server = libherb.init_server();

if not wlr_backend_start(herb_server.backend):
  libherb.deinit_server(addr(herb_server));

wl_display_run(herb_server.server);

libherb.deinit_server(addr(herb_server));
