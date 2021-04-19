logger = pct.util.Logger();
logger.include_everything = false;
logger.include_tags{end+1} = 'reward';
logger.include_tags{end+1} = 'juice_reward';
logger.include_tags{end+1} = 'pause_state';
pct.util.set_logger( logger );

KbName( 'UnifyKeyNames' );
Screen( 'Preference', 'VisualDebuglevel', 0 );

pct_define_config_setup1();
conf = pct.config.reconcile( pct.config.load() );

conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.gaze_source_type_m2 = 'generator';
conf.INTERFACE.reward_output_type = 'none'; %'none'; 'ni';
conf.INTERFACE.display_task_progress = false;

conf.SCREEN.rect = [0, 0, 800, 800];
conf.SCREEN.index = 0;
% Debug screen
conf.DEBUG_SCREEN.is_present = false;

%%%%%%%%%%%%%%
% Start task %
%%%%%%%%%%%%%%
pct.task.fixation.start( conf, ...
  'training_stage_manager_config_func', @pct.training.configure.noop ...
);