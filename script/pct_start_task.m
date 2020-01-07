conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;

conf.META.subject = '';

pct.task.fixation.start( conf );