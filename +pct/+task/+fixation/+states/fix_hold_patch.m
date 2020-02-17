function state = fix_hold_patch(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'fix_hold_patch';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% Reset fix acquired state and target state.
state.UserData.fixation_acquired_state = fixation_acquired_state();
reset( program.Value.targets.fix_hold_square );

reset_targets( program );
position_stimuli( state, program );

timestamp_entry( state, program );
update_last_state( state, program );

end

function loop(state, program)

draw_target( program );
draw_patches( program );
draw_cursor( program );
flip( program.Value.window );

debug_window_is_present = program.Value.debug_window_is_present;
if (debug_window_is_present)
  draw_debug_target( program );
  draw_debug_patches( program );
  draw_debug_cursor( program );
  flip( program.Value.debug_window );
end

check_target( state, program );

end

function exit(state, program)

fix_acq_state = state.UserData.fixation_acquired_state;

if ( fix_acq_state.Acquired )
  timestamp_exit( state, program );
  did_fixate( state, program, fix_acq_state.Acquired );
  next( state, program.Value.states('just_patches') );
else
  timestamp_exit( state, program );
  did_fixate( state, program, fix_acq_state.Acquired );
  next( state, program.Value.states('error_penalty') );
end

end

function fix_state = fixation_acquired_state()

fix_state = struct();
fix_state.Acquired = false;
fix_state.Entered = false;
fix_state.Broke = false;

end

function timestamp_entry(state, program)

program.Value.data.Value(end).(state.Name).entry_time = elapsed( program.Value.task );

end

function timestamp_exit(state, program)

program.Value.data.Value(end).(state.Name).exit_time = elapsed( program.Value.task );

end

function update_last_state(state, program)

program.Value.data.Value(end).last_state = 'fhp';

end

function draw_target(program)

is_debug = pct.util.is_debug( program );
window = program.Value.window;
fix_hold_square = program.Value.stimuli.fix_hold_square;
fix_hold_target = program.Value.targets.fix_hold_square;

draw( fix_hold_square, window );

if ( is_debug )
  draw( fix_hold_target.Bounds, window );
end

end

function draw_debug_target(program)

is_debug = true;
window = program.Value.debug_window;
fix_hold_square = program.Value.stimuli.fix_hold_square;
fix_hold_target = program.Value.targets.fix_hold_square;

draw( fix_hold_square, window );

if ( is_debug )
  draw( fix_hold_target.Bounds, window );
end

end

function draw_patches( program )

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
window = program.Value.window;
patch_targets = program.Value.patch_targets;

is_debug = pct.util.is_debug( program );

for i = 1:num_patches
  stimulus = stimuli.(pct.util.nth_patch_stimulus_name(i));
  draw( stimulus, window );
  
  if ( is_debug )
    draw( patch_targets{i}.Bounds, window );
  end
end

end

function draw_debug_patches(program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
window = program.Value.debug_window;
patch_targets = program.Value.patch_targets;

is_debug = true;

for i = 1:num_patches
  stimulus = stimuli.(pct.util.nth_patch_stimulus_name(i));
  draw( stimulus, window );
  
  if ( is_debug )
    draw( patch_targets{i}.Bounds, window );
  end
end

end


function draw_cursor(program)

is_debug = pct.util.is_debug( program );
pct.util.draw_gaze_cursor( program, is_debug );

end

function draw_debug_cursor(program)

is_debug = true;
pct.util.draw_gaze_cursor( program, is_debug );

end

function check_target(state, program)

fix_hold_target = program.Value.targets.fix_hold_square;
fix_acq_state = state.UserData.fixation_acquired_state;

if ( fix_hold_target.IsDurationMet )
  % Looked for long enough, so proceed to the exit function.
  fix_acq_state.Acquired = true;
  escape( state );
  
elseif ( fix_hold_target.IsInBounds )
  % Mark that we entered the target.
  fix_acq_state.Entered = true;
  
elseif ( fix_acq_state.Entered )
  % Looked away from the target, so proceed to the exit function.
  fix_state.Broke = true;
  escape( state );
end

state.UserData.fixation_acquired_state = fix_acq_state;

end

function position_stimuli(state, program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
pos_vec = [.35, .65];

for i = 1:num_patches
  stim_name = pct.util.nth_patch_stimulus_name( i );
  new_pos = [pos_vec(randi(length(pos_vec))) pos_vec(randi(length(pos_vec)))];
  stimulus = stimuli.(stim_name);
  stimulus.Position.Value = new_pos;
end

end

function reset_targets(program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
default_color = default_patch_color( program );

for i = 1:num_patches
  stim_name = pct.util.nth_patch_stimulus_name( i );
  stimulus = stimuli.(stim_name);
  stimulus.FaceColor = default_color;
end

patch_targets = program.Value.patch_targets;

for i = 1:numel(patch_targets)
  reset( patch_targets{i} );
end

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

end

function color = default_patch_color(program)

color = program.Value.stimuli_setup.patch.color;

end

function did_fixate(state,program,fix_acq_state)

program.Value.data.Value(end).(state.Name).did_fixate = fix_acq_state;
  
end