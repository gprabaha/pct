function program = setup(varargin)

conf = pct.config.reconcile( pct.util.require_config(varargin{:}) );
program = make_program( conf );

try
  make_all( program, conf );
catch err
  delete( program );
  rethrow( err );
end

end

function make_all(program, conf)

make_task( program, conf );
make_states( program, conf );
make_data( program, conf );

updater = make_component_updater( program );
window = make_window( program, conf );
open( window );

tracker = make_eye_tracker( program, updater, conf );
make_eye_tracker_sync( program, conf );
sampler = make_gaze_sampler( program, updater, tracker, conf );

make_arduino_reward_manager( program, conf );

stimuli = make_stimuli( program, conf );
make_targets( program, updater, window, sampler, stimuli, conf );

make_structure( program, conf );
make_interface( program, conf );

handle_cursor( program, conf );
handle_keyboard( program, conf );

end

function handle_cursor(program, conf)

interface = get_interface( conf );

if ( interface.use_mouse && interface.allow_hide_mouse )
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
window.SkipSyncTests = conf.INTERFACE.skip_sync_tests;

program.Value.window = window;

end

function states = make_states(program, conf)

states = containers.Map();
state_names = { 'new_trial', 'fixation', 'fix_hold_patch', ...
    'just_patches', 'error_penalty', 'juice_reward' };

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

function targets = make_targets(program, updater, window, sampler, stimuli, conf)

stim_setup = get_stimuli_setup( conf );
stim_names = fieldnames( stim_setup );
structure = get_structure( conf );

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
        
        target = make_target( stim_descr, stimulus, sampler, window );
        updater.add_component( target );
        
        targets.(stim_name) = target;
        patch_targets{j} = target;
      end
    else
      stimulus = stimuli.(stim_name);
      target = make_target( stim_descr, stimulus, sampler, window );
      updater.add_component( target );
      targets.(stim_name) = target;
    end
  end
end

program.Value.targets = targets;
program.Value.patch_targets = patch_targets;

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

function tracker = make_eye_tracker(program, updater, conf)

interface = get_interface( conf );
use_mouse = interface.use_mouse;

if ( use_mouse )
  tracker = ptb.sources.Mouse();
else
  tracker = ptb.sources.Eyelink();
  initialize( tracker );
  start_recording( tracker );
end

updater.add_component( tracker );
program.Value.tracker = tracker;

end

function make_eye_tracker_sync(program, conf)

sync_info = struct();
sync_info.timer = nan;
sync_info.times = [];
sync_info.next_iteration = 1;
sync_info.tracker_sync_interval = conf.INTERFACE.tracker_sync_interval;

program.Value.tracker_sync = sync_info;

end

function sampler = make_gaze_sampler(program, updater, tracker, conf)

sampler = ptb.samplers.Pass();
sampler.Source = tracker;

updater.add_component( sampler );

program.Value.sampler = sampler;

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

function make_arduino_reward_manager(program, conf)

serial = get_serial( conf );
interface = get_interface( conf );
rewards = get_rewards( conf );

port = serial.port;
messages = struct();
channels = serial.channels;

if ( interface.use_reward )
    arduino_reward_manager = serial_comm.SerialManager( port, messages, channels );
    start( arduino_reward_manager );
else
    arduino_reward_manager = [];
end

program.Value.arduino_reward_manager = arduino_reward_manager;
program.Value.rewards = rewards;

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