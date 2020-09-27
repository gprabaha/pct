KbName( 'UnifyKeyNames' );

Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;
conf.TIMINGS.time_in.just_patches = 10;
conf.TIMINGS.time_in.juice_reward = 1;
conf.TIMINGS.time_in.pause = 5;

conf.META.subject = 'hitch';

conf.INTERFACE.gaze_source_type = 'digital_eyelink';
conf.INTERFACE.gaze_source_type_m2 = 'DebugGenerator';

conf.INTERFACE.reward_output_type = 'ni';
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.save_data = true;
conf.INTERFACE.has_m2 = true;

conf.STIMULI.patch_distribution_radius = 0.16;
conf.STIMULI.setup.fix_square.target_padding = 20;
conf.STIMULI.setup.fix_hold_square.target_padding = 20;

conf.STIMULI.setup.gaze_cursor_m2.visible = true;
conf.STIMULI.setup.gaze_cursor_m2.saccade_time = 0.6; % saccade time.

% Pause every 10 trials.
conf.STRUCTURE.pause_state_criterion = ...
  @(program) pct.util.pause_after_num_trials(program, 10);
conf.STRUCTURE.patch_generator = @(program) pct.util.BlockedCompeteCooperate;
conf.STRUCTURE.num_patches = 1;
conf.STRUCTURE.initial_stage_name = 'PatchFix4';

conf.SCREEN.rect = [];
conf.SCREEN.index = 4;
conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

conf.STIMULI.setup.fix_square.size = [80, 80];
conf.STIMULI.setup.fix_hold_square.size = [80, 80];
conf.STIMULI.setup.patch.size = [100, 100];
conf.STIMULI.setup.gaze_cursor_m2.color = [ 255, 0, 255 ];

% Optionally use an image for the cursor
conf.STIMULI.setup.gaze_cursor_m2.use_image = true;
conf.STIMULI.setup.gaze_cursor_m2.image_file = '';
conf.STIMULI.setup.gaze_cursor_m2.size = [20 20];
conf.STIMULI.setup.gaze_cursor.use_image = true;
conf.STIMULI.setup.gaze_cursor.image_file = '';
conf.STIMULI.setup.gaze_cursor.size = [20 20];

% Optionally use a handle to a different function to change the appearance
% properties of a patch.
conf.STIMULI.setup.patch.patch_appearance_func = ...
  @pct.util.default_patch_appearance;

conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% conf.DEBUG_SCREEN.rect = [ 600, 600, 1000, 1000 ];
conf.DEBUG_SCREEN.rect = [ 1600, 0, 1600 + 1280, 1024 ];

conf.REWARDS.training = 0.4;

pct.config.save( conf );

pct.task.fixation.start( conf ...
  , 'training_stage_manager_config_func', @pct.training.configure.fixation_training ...
);