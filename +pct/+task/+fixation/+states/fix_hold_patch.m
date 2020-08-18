
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

should_abort = false;
fix_hold_square = program.Value.targets.fix_hold_square;
fix_square = program.Value.targets.fix_square;

if ( ~fix_hold_square.IsInBounds || ~fix_square.IsInBounds )
  should_abort = true;
end

reset( program.Value.targets.fix_hold_square );

reset_targets( program );

timestamp_entry( state, program );
update_last_state( state, program );

if ( should_abort )
  escape( state );
  return;
end

end

function loop(state, program)

main_window = program.Value.window;

draw_target( program );
draw_patches( program, main_window );
draw_cursor( program );
flip( main_window );

debug_window_is_present = program.Value.debug_window_is_present;
if (debug_window_is_present)
  debug_window = program.Value.debug_window;
  
  draw_debug_target( program );
  draw_patches( program, debug_window );
  draw_debug_cursor( program );
  flip( debug_window );
end

check_target( state, program );

end

function exit(state, program)

fix_acq_state = state.UserData.fixation_acquired_state;
quantity = 0.05;

if ( fix_acq_state.Acquired )
  timestamp_exit( state, program );
  did_fixate( state, program, fix_acq_state.Acquired );
  pct.util.deliver_reward( program, 1, quantity );
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

function draw_patches(program, window)

stimuli = program.Value.current_patch_stimuli;
patch_targets = { program.Value.current_patches.Target };
is_debug = pct.util.is_debug( program );

for i = 1:numel(stimuli)
  stimulus = stimuli{i};
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
  if ( ~fix_acq_state.Entered )
    fprintf( '\n\n=====Entered======\n\n' );
  end
  fix_acq_state.Entered = true;
  
elseif ( fix_acq_state.Entered )
  % Looked away from the target, so proceed to the exit function.
  fix_state.Broke = true;
  escape( state );
end

state.UserData.fixation_acquired_state = fix_acq_state;

end

function reset_targets(program)

patch_targets = program.Value.patch_targets;

for i = 1:numel(patch_targets)
  reset( patch_targets{i} );
end

end

function did_fixate(state,program,fix_acq_state)

program.Value.data.Value(end).(state.Name).did_fixate = fix_acq_state;
  
end