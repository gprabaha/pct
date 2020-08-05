function program = setup(conf, varargin)

defaults = struct();
defaults.training_stage_manager_config_func = @noop;

params = shared_utils.general.parsestruct( defaults, varargin );

if ( nargin == 0 )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

conf = pct.config.reconcile( conf );
program = make_program( conf );

try
  make_all( program, conf, params );
catch err
  delete( program );
  rethrow( err );
end

end

function make_all(program, conf, params)

make_task( program, conf );
make_states( program, conf );
make_data( program, conf );
make_online_data_rep( program, conf );
make_training_stage_name( program, conf );
make_percentage_correct_recorder( program, conf );

keyboard_queue = make_keyboard_queue( program );
make_key_listeners( program, keyboard_queue );

make_pause_flag( program, conf );

training_stage_manager = make_training_stage_manager( program, conf );

make_training_data( program, conf, params, training_stage_manager );

ni_session = make_ni_daq_session( program, conf );
ni_scan_input = make_ni_scan_input( program, conf, ni_session );
ni_scan_output = make_ni_scan_output( program, conf, ni_session );

updater = make_component_updater( program );
window = make_window( program, conf );
open( window );
debug_window_is_present = conf.DEBUG_SCREEN.is_present;
if (debug_window_is_present)
  debug_window = make_debug_window( program, conf );
  open( debug_window );
else
  program.Value.debug_window_is_present = false;
end

[tracker_m1, tracker_m2] = make_eye_trackers( program, updater, ni_scan_input, conf );
[sampler_m1, sampler_m2] = make_gaze_samplers( program, updater, tracker_m1, tracker_m2 );

make_eye_tracker_sync( program, conf );

make_reward_manager( program, conf, ni_scan_output );

stimuli = make_stimuli( program, conf );
make_targets( program, updater, window, sampler_m1, sampler_m2, stimuli, conf );

make_structure( program, conf );
make_interface( program, conf );

handle_cursor( program, conf );
handle_keyboard( program, conf );

end

function handle_cursor(program, conf)

interface = get_interface( conf );

if ( interface.allow_hide_mouse )
  HideCursor();
end

end

function handle_keyboard(program, conf)

ListenChar( 2 );

end

function program = make_program(conf)

program = ptb.Reference( struct() );
program.Destruct = @pct.task.fixation.shutdown;
program.Value.debug = struct();
program.Value.config = conf;

end

function data = make_data(program, conf)

data = ptb.Reference();
program.Value.data = data;

end

function manager = make_training_stage_manager(program, conf)

manager = pct.util.TrainingStageManager();
program.Value.training_stage_manager = manager;

end

function make_training_data(program, conf, params, manager)

initial_stage_name = conf.STRUCTURE.initial_stage_name;
program.Value.training_data = struct();
program.Value.training_data.should_advance = false;
program.Value.training_data.should_revert = false;
program.Value.training_data.initial_stage_name = initial_stage_name;

params.training_stage_manager_config_func( manager, program );

end

function make_training_stage_name(program, conf)

program.Value.training_stage_name = '';

end

function make_pause_flag( program, conf )

program.Value.pause_flag = false;

end

function online_data_rep = make_online_data_rep(program, conf)

online_data_rep = ptb.Reference();
program.Value.online_data_rep = online_data_rep;

end

function make_percentage_correct_recorder( program, conf )

program.Value.last_n_percent_correct = nan;

end

function ni_session = make_ni_daq_session(program, conf)

ni_session = [];
signal = get_signal( conf );

if ( ~need_make_ni_session(conf) )
  program.Value.ni_session = ni_session;
  program.Value.ni_device_id = '';
  return
end

ni_session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

m1_channel_x = signal.analog_channel_m1x;
m1_channel_y = signal.analog_channel_m1y;

channels = { m1_channel_x, m1_channel_y };

for i = 1:numel(channels)
  addAnalogInputChannel( ni_session, ni_device_id, channels{i}, 'Voltage' );
end

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );

program.Value.ni_session = ni_session;
program.Value.ni_device_id = ni_device_id;

end

function ni_scan_input = make_ni_scan_input(program, conf, ni_session)

ni_scan_input = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_input = [];
  return
end

ni_scan_input = ptb.signal.SingleScanInput( ni_session );
program.Value.ni_scan_input = ni_scan_input;

end

function ni_scan_output = make_ni_scan_output(program, conf, ni_session)

ni_scan_output = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_output = [];
  return
end

ni_scan_output = ptb.signal.SingleScanOutput( ni_session );
program.Value.ni_scan_output = ni_scan_output;

end

function structure = make_structure(program, conf)

structure = get_structure( conf );
program.Value.structure = structure;

end

function interface = make_interface(program, conf)

interface = get_interface( conf );
program.Value.interface = interface;

end

function updater = make_component_updater(program)

updater = ptb.ComponentUpdater();
program.Value.updater = updater;

end

function window = make_window(program, conf)

window = ptb.Window();
window.BackgroundColor = conf.SCREEN.background_color;
window.Rect = conf.SCREEN.rect;
window.Index = conf.SCREEN.index;
window.SkipSyncTests = conf.INTERFACE.skip_sync_tests;

program.Value.window = window;

end

function debug_window = make_debug_window(program, conf)

debug_window = ptb.Window();
debug_window.Index = conf.DEBUG_SCREEN.index;
debug_window.BackgroundColor = conf.DEBUG_SCREEN.background_color;
debug_window.Rect = conf.DEBUG_SCREEN.rect;
debug_window.SkipSyncTests = conf.INTERFACE.skip_sync_tests;

program.Value.debug_window_is_present = true;
program.Value.debug_window = debug_window;

end

function states = make_states(program, conf)

states = containers.Map();
state_names = { 'new_trial', 'fixation', 'fix_hold_patch', ...
    'just_patches', 'error_penalty', 'juice_reward', 'pause' };

for i = 1:numel(state_names)
  state_func = sprintf( 'pct.task.fixation.states.%s', state_names{i} );
  states(state_names{i}) = feval( state_func, program, conf );
end

program.Value.states = states;

end

function stimuli = make_stimuli(program, conf)

structure = get_structure( conf );
stim_setup = get_stimuli_setup( conf );
stim_names = fieldnames( stim_setup );

stimuli = struct();

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  
  if ( strcmp(stim_name, 'patch') )
    % Generate structure.num_patches patch stimuli.
    for j = 1:structure.num_patches
      use_name = pct.util.nth_patch_stimulus_name( j );
      stimuli.(use_name) = make_stimulus( stim_setup.(stim_name) );
    end
  else
    % Otherwise, just generate a single stimulus.
    stimuli.(stim_name) = make_stimulus( stim_setup.(stim_name) );
  end
end

program.Value.stimuli = stimuli;
program.Value.stimuli_setup = stim_setup;

end

function targets = make_targets(program, updater, window ...
  , sampler_m1, sampler_m2, stimuli, conf)

stim_setup = get_stimuli_setup( conf );
stim_names = fieldnames( stim_setup );
structure = get_structure( conf );
patch_distribution_radius =  get_patch_distribution_radius( conf );

targets = struct();
patch_targets = {};

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  stim_descr = stim_setup.(stim_name);
  
  if ( stim_descr.has_target )
    if ( strcmp(stim_name, 'patch') )
      num_patches = structure.num_patches;
      patch_targets = cell( num_patches, 1 );
      
      for j = 1:num_patches
        stim_name = pct.util.nth_patch_stimulus_name( j );
        stimulus = stimuli.(stim_name);
        
%         target = make_target( stim_descr, stimulus, sampler_m2, window );
        target = make_multi_source_target( stim_descr, stimulus ...
          , sampler_m1, sampler_m2, window );
        updater.add_component( target );
        
        targets.(stim_name) = target;
        patch_targets{j} = target;
      end
    else
      stimulus = stimuli.(stim_name);
      target = make_target( stim_descr, stimulus, sampler_m1, window );
      updater.add_component( target );
      targets.(stim_name) = target;
    end
  end
end

program.Value.targets = targets;
program.Value.patch_targets = patch_targets;
program.Value.patch_distribution_radius = patch_distribution_radius;

end

function target = make_multi_source_target(stim_descr, stimulus ...
  , sampler_m1, sampler_m2, window)

target = ptb.XYMultiSourceTarget();
add_sampler( target, sampler_m1 );
add_sampler( target, sampler_m2 );

switch ( stim_descr.class )
  case {'Rect', 'Oval'}
    bounds = ptb.bounds.Rect();
    bounds.BaseRect = ptb.rects.MatchRectangle( stimulus );
    bounds.BaseRect.Rectangle.Window = window;
    bounds.Padding = stim_descr.target_padding;
    
  otherwise
    error( 'Unrecognized stimulus class "%s".', stim_descr.class );
end

target.Bounds = bounds;
target.Duration = stim_descr.target_duration;

end

function target = make_target(stim_descr, stimulus, sampler, window)

target = ptb.XYTarget();
target.Sampler = sampler;

switch ( stim_descr.class )
  case {'Rect', 'Oval'}
    bounds = ptb.bounds.Rect();
    bounds.BaseRect = ptb.rects.MatchRectangle( stimulus );
    bounds.BaseRect.Rectangle.Window = window;
    bounds.Padding = stim_descr.target_padding;
    
  otherwise
    error( 'Unrecognized stimulus class "%s".', stim_descr.class );
end

target.Bounds = bounds;
target.Duration = stim_descr.target_duration;

end

function stim = make_stimulus(description)

switch ( description.class )
  case 'Rect'
    stim = ptb.stimuli.Rect();
  case 'Oval'
    stim = ptb.stimuli.Oval();
  otherwise
    error( 'Unrecognized stimulus class "%s".', description.class );
end

if ( isfield(description, 'position') )
  stim.Position = description.position;
  stim.Position.Units = 'normalized';
end

stim.Scale = ptb.WindowDependent( description.size );
stim.Scale.Units = 'px';
stim.FaceColor = set( ptb.Color(), description.color );

end

function [tracker_m1, tracker_m2] = make_eye_trackers(program, updater, ni_scan_input, conf)

interface = get_interface( conf );
signal = get_signal( conf );

saccade_time = conf.STIMULI.setup.gaze_cursor_m2.saccade_time;

m1_source_type = interface.gaze_source_type;
m2_source_type = interface.gaze_source_type_m2;

m1_channel_indices = signal.analog_gaze_input_channel_indices_m1;
m2_channel_indices = signal.analog_gaze_input_channel_indices_m2;

calibration_rect = conf.CALIB_SCREEN.rect;

tracker_m1 = make_eye_tracker( updater, ni_scan_input ...
  , m1_channel_indices, calibration_rect, m1_source_type );

tracker_m2 = make_eye_tracker( updater, ni_scan_input ...
  , m2_channel_indices, calibration_rect, m2_source_type );

if ( interface.m2_is_computer )
  generator_m2 = pct.generators.DebugGenerator( tracker_m2 );
else
  generator_m2 = [];
end

program.Value.tracker = tracker_m1;
program.Value.tracker_m2 = tracker_m2;
program.Value.generator_m2 = generator_m2;
program.Value.generator_m2_saccade_time = saccade_time;

end

function tracker = ...
  make_eye_tracker(updater, ni_scan_input, input_channel_indices, calibration_rect, source_type)

switch ( source_type )
  case 'mouse'
    tracker = ptb.sources.Mouse();
    
  case 'digital_eyelink'
    tracker = ptb.sources.Eyelink();
    initialize( tracker );
    start_recording( tracker );
    
  case 'analog_input'
    tracker = make_analog_input_tracker( ni_scan_input, input_channel_indices, calibration_rect );
    
  case 'DebugGenerator'
    tracker = make_debug_generator_tracker();
    
  otherwise
    error( 'Unrecognized source type "%s".', source_type );
end

updater.add_component( tracker );

end

function tracker = make_analog_input_tracker(ni_scan_input, channel_indices, calibration_rect)

tracker = ptb.sources.XYAnalogInput( ni_scan_input );
tracker.CalibrationRect = calibration_rect;
tracker.OutputVoltageRange = [-5, 5];
tracker.CalibrationRectPaddingFract = [0.2, 0.2];
tracker.ChannelMapping = channel_indices;

end

function tracker = make_debug_generator_tracker()

tracker = ptb.sources.Generator();

end

function make_eye_tracker_sync(program, conf)

sync_info = struct();
sync_info.timer = nan;
sync_info.times = [];
sync_info.next_iteration = 1;
sync_info.tracker_sync_interval = conf.INTERFACE.tracker_sync_interval;

program.Value.tracker_sync = sync_info;

end

function [sampler_m1, sampler_m2] = ...
  make_gaze_samplers(program, updater, tracker_m1, tracker_m2)

sampler_m1 = make_gaze_sampler( updater, tracker_m1 );
sampler_m2 = make_gaze_sampler( updater, tracker_m2 );

program.Value.sampler = sampler_m1;
program.Value.sampler_m2 = sampler_m2;

end

function sampler = make_gaze_sampler(updater, tracker)

sampler = ptb.samplers.Pass();
sampler.Source = tracker;

updater.add_component( sampler );

end

function task = make_task(program, conf)

time_in = get_time_in( conf );
interface = get_interface( conf );

task = ptb.Task();

task.Duration = time_in.task;
task.Loop = @(task) pct.task.fixation.loop(task, program);
task.exit_on_key_down( interface.stop_key );
% task.add_exit_condition( @() numel(program.Value.data.Value) > 10 );

program.Value.task = task;

end

function make_reward_manager(program, conf, ni_scan_output)

initialize_reward_manager_variables( program, conf );

if ( is_arduino_reward_source(conf) )
  make_arduino_reward_manager( program, conf );
elseif ( is_ni_reward_source(conf) )
  make_ni_reward_manager( program, conf, ni_scan_output );  
end

program.Value.rewards = get_rewards( conf );

end

function initialize_reward_manager_variables(program, conf)

program.Value.arduino_reward_manager = [];
program.Value.ni_reward_manager = [];

end

function make_ni_reward_manager(program, conf, ni_scan_output)

channel_index = 1;
reward_manager = ptb.signal.SingleScanOutputPulseManager( ni_scan_output, channel_index );

program.Value.ni_reward_manager = reward_manager;

end

function make_arduino_reward_manager(program, conf)

serial = get_serial( conf );

port = serial.port;
messages = struct();
channels = serial.channels;

arduino_reward_manager = serial_comm.SerialManager( port, messages, channels );
start( arduino_reward_manager );

program.Value.arduino_reward_manager = arduino_reward_manager;

end

function queue = make_keyboard_queue(program)

queue = ptb.keyboard.Queue();
start( queue );
program.Value.keyboard_queue = queue;

end

function make_key_listeners(program, keyboard_queue)

add_listener( keyboard_queue ...
  , @(key_state) pct.training.fixation_training_stage_key_listener(key_state, program) );

end

function tf = need_make_ni_session(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'ni' ) || ...
  is_analog_input_gaze_source( conf );
end

function tf = is_ni_reward_source(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'ni' );
end

function tf = is_arduino_reward_source(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'arduino' );
end

function tf = is_analog_input_gaze_source(conf)
tf = strcmp( conf.INTERFACE.gaze_source_type, 'analog_input' );
end

function tf = is_mouse_gaze_source(conf)
tf = strcmp( conf.INTERFACE.gaze_source_type, 'mouse' );
end

function rewards = get_rewards(conf)
rewards = conf.REWARDS;
end

function serial = get_serial(conf)
serial = conf.SERIAL;
end

function structure = get_structure(conf)
structure = conf.STRUCTURE;
end

function setup = get_stimuli_setup(conf)
setup = conf.STIMULI.setup;
end

function interface = get_interface(conf)
interface = conf.INTERFACE;
end

function time_in = get_time_in(conf)
time_in = conf.TIMINGS.time_in;
end

function signal = get_signal(conf)
signal = conf.SIGNAL;
end

function patch_distribution_radius = get_patch_distribution_radius( conf )
patch_distribution_radius = conf.STIMULI.patch_distribution_radius;
end

function varargout = noop(varargin)
% Do nothing.
end