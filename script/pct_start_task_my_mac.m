Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;
conf.TIMINGS.time_in.just_patches = 10;
conf.TIMINGS.time_in.juice_reward = 1;
conf.TIMINGS.time_in.pause = 2;

conf.META.subject = 'human';

conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.gaze_source_type_m2 = 'DebugGenerator';

conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.save_data = false;
conf.INTERFACE.has_m2 = true;

conf.STIMULI.patch_distribution_radius = 0.35;
conf.STIMULI.setup.gaze_cursor_m2.visible = true;
conf.STIMULI.setup.gaze_cursor_m2.saccade_time = 0.3;

conf.STRUCTURE.pause_state_criterion = @(program) pct.util.pause_after_num_trials(program, 5);
conf.STRUCTURE.num_patches = 2;
conf.STRUCTURE.initial_stage_name = 'FixHold11';


conf.SCREEN.rect = [ 0, 0, 560, 350 ];
conf.SCREEN.index = 0;
% conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

conf.STIMULI.setup.fix_square.size = [ 100, 100 ];
conf.STIMULI.setup.fix_hold_square.size = [ 100, 100 ];
conf.STIMULI.setup.patch.size = [ 100, 100 ];
conf.STIMULI.setup.gaze_cursor_m2.color = [ 255, 0, 255 ];

conf.STIMULI.setup.patch.patch_identity_color_map('m1') = [255, 0, 0];
conf.STIMULI.setup.patch.patch_identity_color_map('m2') = [0, 0, 255];

conf.DEBUG_SCREEN.is_present = false;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% conf.DEBUG_SCREEN.rect = [ 600, 600, 1000, 1000 ];
conf.DEBUG_SCREEN.rect = [ 1600, 0, 1600 + 1280, 1024 ];

conf.REWARDS.training = 0.2;

pct.config.save( conf );

pct.task.fixation.start( conf ...
  , 'training_stage_manager_config_func', @pct.training.configure.fixation_training ...
);