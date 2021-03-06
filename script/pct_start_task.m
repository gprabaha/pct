Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;
conf.TIMINGS.time_in.just_patches = 10;
conf.TIMINGS.time_in.juice_reward = 1;
conf.TIMINGS.time_in.pause = 120;

conf.META.subject = 'hitch';

% conf.INTERFACE.gaze_source_type = 'analog_input';
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
% conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.reward_output_type = 'ni'; 
% conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.save_data = true;

conf.STIMULI.patch_distribution_radius = 0.19;
conf.STIMULI.setup.fix_square.target_padding = 60;
conf.STIMULI.setup.fix_hold_square.target_padding = 60;
conf.STIMULI.setup.patch.target_padding = 60;

conf.STIMULI.setup.fix_square.color = [255 255 255];
conf.STIMULI.setup.fix_hold_square.color = [255 255 255];

conf.STIMULI.setup.fix_square.size = [60, 60];
conf.STIMULI.setup.fix_hold_square.size = [60, 60];
conf.STIMULI.setup.patch.size = [60, 60];

conf.STRUCTURE.pause_state_criterion = @(program) pct.util.pause_after_num_trials(program, 300);
conf.STRUCTURE.num_patches = 3;
conf.STRUCTURE.initial_stage_name = 'PatchFix4';

% conf.SCREEN.rect = [0, 0, 1280, 1024];
conf.SCREEN.rect = [];
conf.SCREEN.index = 4;
conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% conf.DEBUG_SCREEN.rect = [ 600, 600, 1000, 1000 ];
conf.DEBUG_SCREEN.rect = [ 1600, 0, 1600 + 1280, 1024 ];

conf.REWARDS.training = 0.25;

pct.task.fixation.start( conf ...
  , 'training_stage_manager_config_func', @pct.training.configure.fixation_training ...
);