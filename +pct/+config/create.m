
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.

if ( nargin < 1 ), do_save = false; end

const = pct.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( pct.util.get_project_folder() );
PATHS.data = fullfile( pct.util.get_project_folder(), 'data' );
PATHS.remote = fullfile( pct.util.get_project_folder(), 'remote' );

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'ptb', 'ptb_helpers', 'serial_comm' };

%	INTERFACE
INTERFACE = struct();
INTERFACE.stop_key = ptb.keys.esc();
INTERFACE.gaze_source_type = 'mouse'; % 'digital_eyelink', 'analog_input'
INTERFACE.gaze_source_type_m2 = 'mouse';  % 'analog_input'; NOT 'digital_eyelink'
INTERFACE.reward_output_type = 'none';  % 'arduino', 'ni'
INTERFACE.use_reward = false;
INTERFACE.allow_hide_mouse = true;
INTERFACE.is_debug = false;
INTERFACE.tracker_sync_interval = 1;
INTERFACE.skip_sync_tests = false;
INTERFACE.save_data = true;
INTERFACE.display_task_progress = true;
INTERFACE.has_m2 = false;
INTERFACE.m2_is_computer = true;

%   META
META = struct();
META.m1_subject = '';
META.m2_subject = '';

%	SCREEN
SCREEN = struct();

SCREEN.full_size = get( 0, 'screensize' );
SCREEN.index = 3;
SCREEN.background_color = [ 0 0 0 ];
SCREEN.rect = [0, 0, 1280, 1024];

% CALIBRATION SCREEN
CALIB_SCREEN = struct();

CALIB_SCREEN.full_size = get( 0, 'screensize' );
CALIB_SCREEN.index = 3;
CALIB_SCREEN.rect = [0, 0, 1280, 1024];
CALIB_SCREEN.debug_screen_index = 0;
CALIB_SCREEN.debug_screen_rect = [0, 0, 400, 400];

% DEBUG_SCREEN
DEBUG_SCREEN = struct();

if (length(Screen('Screens')) > 1)
  DEBUG_SCREEN.is_present = true;
else
  DEBUG_SCREEN.is_present = false;
end
DEBUG_SCREEN.full_size = get( 0, 'screensize' );
DEBUG_SCREEN.index = 2;
DEBUG_SCREEN.background_color = [ 0 0 0 ];
DEBUG_SCREEN.rect = [ 0, 0, 400, 400 ];


% STRUCTURE
STRUCTURE = struct();
STRUCTURE.num_patches = 1;
STRUCTURE.initial_stage_name = 'Fixation1';
STRUCTURE.pause_state_criterion = ...
  @(program) pct.util.pause_after_num_trials( program, 300 );

STRUCTURE.patch_params = struct( ...
    'trials_per_block', 10 ...
  , 'next_block_strategy', 'sequential' ...
  , 'block_types', {{'compete', 'cooperate'}} ...
  , 'start_block_type', 'cooperate' ...
);

% Default to using a patch generator that makes info for M1 self patches
% only.
STRUCTURE.patch_generator = @(program) pct.util.PatchInfoM1Only();

%	TIMINGS
TIMINGS = struct();

time_in = struct();
time_in.task = Inf;
time_in.new_trial = 0;
time_in.fixation = 5;
time_in.fix_hold_patch = 5;
time_in.just_patches = Inf;
time_in.error_penalty = 3;
time_in.present_patches = Inf;
time_in.juice_reward = 1;
time_in.pause = 60;

TIMINGS.time_in = time_in;

%	STIMULI
STIMULI = struct();
STIMULI.setup = struct();
STIMULI.patch_distribution_radius = 0.15;

non_editable_properties = {{ 'placement', 'has_target', 'image_matrix' }};

STIMULI.setup.fix_square = struct( ...
    'class',            'Rect' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 255, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.3 ...
  , 'target_padding',   0 ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.fix_hold_square = struct( ...
    'class',            'Rect' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 255, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.5 ...
  , 'target_padding',   0 ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.gaze_cursor = struct( ....
    'class',            'Oval' ...
  , 'size',             [ 25, 25 ] ...
  , 'color',            [ 0, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       false ...
  , 'use_image',        false ...
  , 'image_file',       '' ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.gaze_cursor_m2 = struct( ....
    'class',            'Oval' ...
  , 'size',             [ 25, 25 ] ...
  , 'color',            [ 255, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       false ...
  , 'use_image',        false ...
  , 'image_file',       '' ...
  , 'visible',          false ...
  , 'saccade_speed',    1/0.4 ...
  , 'wait_time',        0.5 ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.patch = struct( ....
    'class',            'Oval' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 255, 0, 0 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.3 ...
  , 'target_padding',   10 ...
  , 'patch_identity_color_map', patch_identity_color_map() ...
  , 'patch_appearance_func', @pct.util.default_patch_appearance ...
  , 'non_editable',     non_editable_properties ...
);

%	SERIAL
SERIAL = struct();
SERIAL.port = 'COM3';
SERIAL.channels = { 'A' };

% SIGNAL
SIGNAL = struct();
SIGNAL.analog_channel_m1x = 'ai0';
SIGNAL.analog_channel_m1y = 'ai1';
SIGNAL.analog_gaze_input_channel_indices_m1 = [1, 2];
SIGNAL.analog_gaze_input_channel_indices_m2 = [3, 4];

%   REWARDS
REWARDS = struct();
REWARDS.training = .3;
REWARDS.pause = .4;
REWARDS.total_reward = 0;

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;
conf.TIMINGS = TIMINGS;
conf.STIMULI = STIMULI;
conf.SCREEN = SCREEN;
conf.CALIB_SCREEN = CALIB_SCREEN;
conf.DEBUG_SCREEN = DEBUG_SCREEN;
conf.INTERFACE = INTERFACE;
conf.STRUCTURE = STRUCTURE;
conf.SERIAL = SERIAL;
conf.META = META;
conf.REWARDS = REWARDS;
conf.SIGNAL = SIGNAL;

if ( do_save )
  pct.config.save( conf );
end

end

function map = patch_identity_color_map()

map = containers.Map();
map('m1') = [255, 0, 0];
map('m2') = [0, 0, 255];
map('compete') = [0, 255, 255];
map('cooperate') = [255, 0, 255];

end