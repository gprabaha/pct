function state = fixation(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'fixation';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% Reset fix acquired state and target state.
state.UserData.fixation_acquired_state = fixation_acquired_state();
reset( program.Value.targets.fix_square );

end

function loop(state, program)

draw_target( program );
draw_cursor( program );
flip( program.Value.window );

check_target( state, program );

end

function exit(state, program)

fix_acq_state = state.UserData.fixation_acquired_state;

if ( fix_acq_state.Acquired )
  disp( 'Acquired fixation - going to present_patches.' );
  next( state, program.Value.states('present_patches') );
else
  disp( 'Failed to acquire fixation - going back to new trial' );
  next( state, program.Value.states('new_trial') );
end

end

function fix_state = fixation_acquired_state()

fix_state = struct();
fix_state.Acquired = false;
fix_state.Entered = false;
fix_state.Broke = false;

end

function draw_target(program)

window = program.Value.window;
fix_square = program.Value.stimuli.fix_square;

draw( fix_square, window );

end

function draw_cursor(program)

pct.util.draw_gaze_cursor( program );

end

function check_target(state, program)

fix_target = program.Value.targets.fix_square;
fix_acq_state = state.UserData.fixation_acquired_state;

if ( fix_target.IsDurationMet )
  % Looked for long enough, so proceed to the exit function.
  fix_acq_state.Acquired = true;
  escape( state );
  
elseif ( fix_target.IsInBounds )
  % Mark that we entered the target.
  fix_acq_state.Entered = true;
  
elseif ( fix_acq_state.Entered )
  % Looked away from the target, so proceed to the exit function.
  fix_state.Broke = true;
  escape( state );
end

state.UserData.fixation_acquired_state = fix_acq_state;

end