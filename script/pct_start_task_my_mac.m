logger = pct.util.Logger();
logger.include_everything = false;
pct.util.set_logger( logger );

KbName( 'UnifyKeyNames' );

Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = pct.config.reconcile( pct.config.load() );

conf.TIMINGS.time_in.fixation = 10;
conf.TIMINGS.time_in.just_patches = 10;
conf.TIMINGS.time_in.juice_reward = 1.5;
conf.TIMINGS.time_in.pause = 25;

conf.META.m1_subject = 'human';
conf.META.m2_subject = 'computer_naive';

conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.gaze_source_type_m2 = 'generator';

conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.save_data = false;
conf.INTERFACE.has_m2 = true;

% Patch display parameters
conf.STIMULI.patch_distribution_radius = 0.3;
conf.STIMULI.setup.fix_square.target_padding = 20;
conf.STIMULI.setup.fix_hold_square.target_padding = 20;

% M2 cursor parameters
conf.STIMULI.setup.gaze_cursor_m2.visible = true;
conf.STIMULI.setup.gaze_cursor_m2.saccade_speed = 1/0.3;

conf.STRUCTURE.pause_state_criterion = @(program) pct.util.pause_after_num_trials(program, 5);
conf.STRUCTURE.num_patches = 2;

% Trial structure parameters
conf.STRUCTURE.patch_params.trials_per_block = 3;
conf.STRUCTURE.patch_generator = ...
  @(program) pct.util.BlockedCompeteCooperate(conf.STRUCTURE.patch_params);
conf.STRUCTURE.pause_state_criterion = ...
  @(program) pct.util.pause_after_num_trials(program, 50);
conf.STRUCTURE.generator_m2 = @(program, tracker) pct.generators.DebugGeneratorManyPatches(tracker);
conf.STRUCTURE.num_patches = 4;
STRUCTURE.prevent_next_patch_repeat = true;

conf.SCREEN.rect = [ 0, 0, 560, 350 ];
conf.SCREEN.index = 0;
% conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

conf.STIMULI.setup.fix_square.size = [ 100, 100 ];
conf.STIMULI.setup.fix_hold_square.size = [ 100, 100 ];
conf.STIMULI.setup.patch.size = [ 100, 100 ];
conf.STIMULI.setup.gaze_cursor_m2.color = [ 255, 0, 255 ];

% Optionally use a handle to a different function to change the appearance
% properties of a patch.
conf.STIMULI.setup.patch.patch_appearance_func = ...
  @pct.util.default_patch_appearance;

conf.DEBUG_SCREEN.is_present = false;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
conf.DEBUG_SCREEN.rect = [ 0, 0, 560, 350 ] + 500;
% conf.DEBUG_SCREEN.rect = [ 1600, 0, 1600 + 1280, 1024 ];

conf.REWARDS.training = 0.2;

%{
begin debug parameters for new task structure
%}

%{

trial_set = pct.util.FourPatchTrialSet();
conf.STRUCTURE.patch_params.trial_set = trial_set;
conf.STIMULI.setup.patch.patch_appearance_func = ...
  @(patch_info) trial_set.patch_appearance(patch_info);

%}

conf.STRUCTURE.error_if_not_all_patches_acquired = false;
conf.STRUCTURE.num_patches = 2;
conf.STRUCTURE.patch_params.persist_patch_info_until_exhausted = true;
conf.STRUCTURE.patch_params.max_num_trials_persist_patch_info = 2;
conf.TIMINGS.time_in.just_patches = 2;
conf.INTERFACE.display_task_progress = false;

%{
end debug parameters
%}

pct.config.save( conf );

pct.task.fixation.start( conf ...
  , 'training_stage_manager_config_func', @pct.training.configure.noop ...
);