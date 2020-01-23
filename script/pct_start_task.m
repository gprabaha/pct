conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;

conf.META.subject = '';

conf.INTERFACE.use_mouse = true;
conf.INTERFACE.use_reward = false;
conf.INTERFACE.skip_sync_tests = true;

conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
conf.DEBUG_SCREEN.rect = [ 600, 600, 1000, 1000 ];

pct.task.fixation.start( conf );