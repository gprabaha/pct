function pct_define_config_setup1()

%%%%%%%%%%%%%%%
% Load config %
%%%%%%%%%%%%%%%
conf = pct.config.reconcile( pct.config.load() );
conf = pct.config.prune( conf );

%%%%%%%%%%%%%%%%%
% Trial details %
%%%%%%%%%%%%%%%%%
conf.STRUCTURE.pause_state_criterion = ...
  @(program) pct.util.pause_after_num_trials(program, 50);
conf.STRUCTURE.num_patches = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial progress display %
%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.INTERFACE.display_task_progress = true;
conf.INTERFACE.num_trials_to_display = 5;

%%%%%%%%%%%%%%
% Generators %
%%%%%%%%%%%%%%

conf.STRUCTURE.patch_params.trial_reps = 100;

conf.STRUCTURE.patch_generator = ...
  @(program) pct.util.BlockedMultiPatchTrials(conf.STRUCTURE.patch_params);

conf.STRUCTURE.generator_m2 = ...
  @(program, tracker, vel_estimator) pct.generators.DebugGeneratorManyPatches( ...
    tracker, vel_estimator ...
    , 'use_velocity_estimator', false ...
    , 'allow_speed_adjustment', false ...
    , 'speed_increment', 0.5 ...
);

%%%%%%%%%%%%%%%%%%
% Reward details %
%%%%%%%%%%%%%%%%%%
conf.REWARDS.training = 0.3;
conf.REWARDS.pause = 0.2;
conf.REWARDS.key_press = 0.2;
conf.REWARDS.bridge = 0.1;

%%%%%%%%%%%%%%%%%%%%%%%%%
% Timings in each state %
%%%%%%%%%%%%%%%%%%%%%%%%%
conf.TIMINGS.time_in.fixation = 5;
conf.TIMINGS.time_in.just_patches = 2.5;
conf.TIMINGS.time_in.juice_reward = 1.5;
conf.TIMINGS.time_in.pause = 60;
conf.TIMINGS.time_in.iti_patch_sequence_1 = 0;
conf.TIMINGS.time_in.iti_patch_sequence_2 = 1;

%%%%%%%%%%%%%%%%%%%
% Subject details %
%%%%%%%%%%%%%%%%%%%
conf.META.m1_agent = 'hitch';
conf.META.m2_agent = 'computer_naive_random';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hardware interface details %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
conf.INTERFACE.gaze_source_type_m2 = 'generator';
conf.INTERFACE.reward_output_type = 'arduino'; %'none'; 'ni';
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.has_m2 = true;

%%%%%%%%%%%%%%%%%%
% Screen details %
%%%%%%%%%%%%%%%%%%
calibration_rect = [0, 0, 1600, 900];

conf.SCREEN.rect = [];
conf.SCREEN.index = 2;
conf.SCREEN.calibration_rect = calibration_rect;
% Debug screen
conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 1;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% Debug screen rect accounts for resolution of monkey monitor
conf.DEBUG_SCREEN.rect = calibration_rect;
% Calib screen
conf.CALIB_SCREEN.full_rect = [];
conf.CALIB_SCREEN.index = 2;
conf.CALIB_SCREEN.calibration_rect = calibration_rect;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation square properties %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.STIMULI.setup.fix_square.size = [100, 100];
conf.STIMULI.setup.fix_square.target_padding = 20;
conf.STIMULI.setup.fix_hold_square.size = [100, 100];
conf.STIMULI.setup.fix_hold_square.target_padding = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Patch display parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.STIMULI.patch_distribution_radius = 0.2;
conf.STIMULI.setup.patch.size = [130, 130];
% Optionally use a handle to a different function to change the appearance
% properties of a patch.
conf.STIMULI.setup.patch.patch_appearance_func = ...
  @pct.util.default_patch_appearance;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M1 and M2 gaze cursor parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M1
conf.STIMULI.setup.gaze_cursor.size = [ 25 25 ];
% M2
conf.STIMULI.setup.gaze_cursor_m2.visible = true;
conf.STIMULI.setup.gaze_cursor_m2.size = [25 25 ];
conf.STIMULI.setup.gaze_cursor_m2.color = [ 255, 0, 255 ];
conf.STIMULI.setup.gaze_cursor_m2.saccade_time = 0.6;
% Optional usage of image for cursor
cursor_path = [repdir '/pct/bitmaps/cursors/'];
conf.STIMULI.setup.gaze_cursor.use_image = true;
conf.STIMULI.setup.gaze_cursor.image_file = fullfile([cursor_path 'gray-triangle.png']);
conf.STIMULI.setup.gaze_cursor_m2.use_image = true;
conf.STIMULI.setup.gaze_cursor_m2.image_file = fullfile([cursor_path 'gray-star.png']);

%%%%%%%%%%%%%%%%%%%
% Port for reward %
%%%%%%%%%%%%%%%%%%%
conf.SERIAL.port = 'COM3';

%%%%%%%%%%%%%%%%%%%
% Save new config %
%%%%%%%%%%%%%%%%%%%
pct.config.save( conf );

end