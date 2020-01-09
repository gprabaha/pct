conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;

conf.META.subject = '';

conf.INTERFACE.use_mouse = false;
conf.INTERFACE.use_reward = true;
conf.INTERFACE.skip_sync_tests = true;

pct.task.fixation.start( conf );