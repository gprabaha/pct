function conf = pct_define_config_setup1(do_save)

if ( nargin < 1 )
  do_save = true;
end

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
conf.STRUCTURE.num_patches = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial progress display %
%%%%%%%%%%%%%%%%%%%%%%%%%%
conf.INTERFACE.display_task_progress = true;
conf.INTERFACE.num_trials_to_display = 5;

%%%%%%%%%%%%%%
% Generators %
%%%%%%%%%%%%%%

conf.STRUCTURE.patch_params.trial_reps = 1000;
conf.STRUCTURE.patch_params.trial_set_generator = pct.util.OnePatchOneReward_TrialSet;
%conf.STRUCTURE.patch_params.trial_set_generator = pct.util.OnePatchManyReward_TrialSet;

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
conf.SCREEN.index = 3;
conf.SCREEN.calibration_rect = calibration_rect;
% Debug screen
conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 1;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
% Debug screen rect accounts for resolution of monkey monitor
conf.DEBUG_SCREEN.rect = calibration_rect;
% Calib screen
conf.CALIB_SCREEN.full_rect = [];
conf.CALIB_SCREEN.index = 3;
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
cursor_path = fullfile( repdir, 'pct/bitmaps/cursors/' );
acquired_patches_path = fullfile( repdir, 'pct/bitmaps/acquired' );
available_patches_patch = fullfile( repdir, 'pct/bitmaps/available' );

conf.STIMULI.setup.gaze_cursor.use_image = true;
conf.STIMULI.setup.gaze_cursor.image_file = fullfile([cursor_path 'gray-triangle.png']);
conf.STIMULI.setup.gaze_cursor_m2.use_image = true;
conf.STIMULI.setup.gaze_cursor_m2.image_file = fullfile([cursor_path 'gray-star.png']);

conf.STIMULI.images = {...
  struct( ...
      'name', 'm1_self_acquired' ...
    , 'file', fullfile(acquired_patches_path, 'm1_self_acquired.png') ...
  ) ...
  , struct( ...
      'name', 'm2_self_acquired' ...
    , 'file', fullfile(acquired_patches_path, 'm2_self_acquired.png') ...
  ) ...
  , struct( ...
      'name', 'compete_acquired' ...
    , 'file', fullfile(acquired_patches_path, 'compete_acquired.png') ...
  ) ...
  , struct( ...
      'name', 'cooperate_acquired' ...
    , 'file', fullfile(acquired_patches_path, 'cooperate_acquired.png') ...
  )
};

n_rewards = 3;
for i = 1:n_rewards
  conf.STIMULI.images{end+1} = struct( ...
      'name', sprintf('m1_self_reward%d', i) ...
    , 'file', fullfile(available_patches_patch, sprintf('m1_self_reward%d.png', i)) ...
  );
  conf.STIMULI.images{end+1} = struct( ...
      'name', sprintf('m2_self_reward%d', i) ...
    , 'file', fullfile(available_patches_patch, sprintf('m2_self_reward%d.png', i)) ...
  );
  conf.STIMULI.images{end+1} = struct( ...
      'name', sprintf('compete_reward%d', i) ...
    , 'file', fullfile(available_patches_patch, sprintf('compete_reward%d.png', i)) ...
  );
  conf.STIMULI.images{end+1} = struct( ...
      'name', sprintf('cooperate_reward%d', i) ...
    , 'file', fullfile(available_patches_patch, sprintf('cooperate_reward%d.png', i)) ...
  );
end

%%%%%%%%%%%%%%%%%%%
% Port for reward %
%%%%%%%%%%%%%%%%%%%
conf.SERIAL.port = 'COM3';

%%%%%%%%%%%%%%%%%%%
% Save new config %
%%%%%%%%%%%%%%%%%%%

if ( do_save )
  pct.config.save( conf );
end

%%%%%%%%%%%%%%%
% Saving data %
%%%%%%%%%%%%%%%
conf.INTERFACE.save_data = true;
conf.PATHS.remote = 'C:\Users\setup1\Dropbox (ChangLab)\prabaha_changlab\pct-training-hitch\patch-with-dots-training-data\OnePatchOneReward';

end