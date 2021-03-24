logger = pct.util.Logger();
logger.include_everything = false;
logger.include_tags{end+1} = 'reward';
logger.include_tags{end+1} = 'pause_state';
pct.util.set_logger( logger );

KbName( 'UnifyKeyNames' );
Screen( 'Preference', 'VisualDebuglevel', 0 );

pct_define_config_setup1();
conf = pct.config.reconcile( pct.config.load() );

%%%%%%%%%%%%%%
% Start task %
%%%%%%%%%%%%%%
pct.task.fixation.start( conf, ...
  'training_stage_manager_config_func', @pct.training.configure.noop ...
);

%%%%%%%%%%%%%%%
% Saving data %
%%%%%%%%%%%%%%%
conf.INTERFACE.save_data = true;
conf.PATHS.remote = 'C:\Users\setup1\Dropbox (ChangLab)\prabaha_changlab\pct-training-hitch\4_patches\old';