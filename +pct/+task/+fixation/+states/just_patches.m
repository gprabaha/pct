function state = just_patches(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'just_patches';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

num_patches = count_patches( program );

% All patches remaining
state.UserData.num_patches_remaining = num_patches;
% No patches were acquired
state.UserData.patch_elapsed_state = false( 1, num_patches );
% The IDs of the agent who acquired the patch.
state.UserData.patch_acquired_by = zeros( 1, num_patches );
% No patches were entered
state.UserData.mark_entered = false( 1, num_patches );
% IDs of the agent who entered the patch.
state.UserData.entered_by = zeros( 1, num_patches );
% No patches were exited
state.UserData.mark_exited = false( 1, num_patches );

reset_targets( program );

handle_computer_generated_m2( program );

timestamp_entry( state, program );
update_last_state( state, program );

end

function loop(state, program)

main_window = program.Value.window;

draw_patches( program, main_window );
draw_cursor( program );
flip( main_window );

debug_window_is_present = program.Value.debug_window_is_present;
if (debug_window_is_present)
  debug_window = program.Value.debug_window;
  
  draw_patches( program, debug_window );
  draw_debug_cursor( program );
  flip( debug_window );
end

check_targets( state, program );

% Exit if all patches were acquired.
if ( state.UserData.num_patches_remaining == 0 )
  escape( state );
end

end

function exit(state, program)

if ( state.UserData.num_patches_remaining == 0 )
  timestamp_exit( state, program );
  next( state, program.Value.states('juice_reward') );
else
  timestamp_exit( state, program );
  next( state, program.Value.states('error_penalty') );
end

end

function timestamp_entry(state, program)

program.Value.data.Value(end).(state.Name).entry_time = elapsed( program.Value.task );

end

function timestamp_exit(state, program)

program.Value.data.Value(end).(state.Name).exit_time = elapsed( program.Value.task );

end

function update_last_state(state, program)

program.Value.data.Value(end).last_state = 'jp';

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

function check_targets(state, program)

patch_info = program.Value.current_patches;
stimuli = program.Value.current_patch_stimuli;

for i = 1:numel(patch_info)
  stimulus = stimuli{i};
  target = patch_info(i).Target;
  
  if ( any(target.IsInBounds) && ...
      ~state.UserData.mark_entered(i) && ~any(target.IsDurationMet) )
    % Entered one of the patches
    patch_entry_timestamp( state, program, i );
    state.UserData.mark_entered(i) = true;
    state.UserData.entered_by(i) = find( target.IsInBounds );
  
  elseif ( state.UserData.mark_entered(i) && ...
      ~any(target.IsInBounds) && ~any(target.IsDurationMet) )
    % Exited one of the patches before duration was met
    patch_exit_timestamp( state, program, i );
    state.UserData.mark_entered(i) = false;
  end
    
  if ( any(target.IsDurationMet) )
    stimulus.FaceColor = [0, 0, 0];
    
    if ( ~state.UserData.patch_elapsed_state(i) )
      % The patch has already been acquired
      patch_acquired_timestamp( state, program, i );
      state.UserData.patch_elapsed_state(i) = true;
      state.UserData.num_patches_remaining = state.UserData.num_patches_remaining - 1;
      state.UserData.patch_acquired_by(i) = find( target.IsDurationMet );
    end
  end
end

end

function reset_targets(program)

patch_targets = program.Value.patch_targets;

for i = 1:numel(patch_targets)
  reset( patch_targets{i} );
end

end

function num_patches = count_patches(program)

num_patches = numel( program.Value.current_patches );

end

function patch_entry_timestamp( state, program, patch_id )

program.Value.data.Value(end).(state.Name).patch_entry_times{patch_id} = ...
    [program.Value.data.Value(end).(state.Name).patch_entry_times{patch_id} ...
    elapsed( program.Value.task )];

end

function patch_exit_timestamp( state, program, patch_id )

program.Value.data.Value(end).(state.Name).patch_exit_times{patch_id} = ...
    [program.Value.data.Value(end).(state.Name).patch_exit_times{patch_id} ...
    elapsed( program.Value.task )];

end

function patch_acquired_timestamp( state, program, patch_id )

program.Value.data.Value(end).(state.Name).patch_acquired_times(patch_id) = ...
    elapsed( program.Value.task );

end

function handle_computer_generated_m2(program)

interface = program.Value.interface;

if ( ~interface.has_m2 || ~interface.m2_is_computer )
  return
end

patch_info = program.Value.current_patches;
initialize( program.Value.generator_m2, patch_info, program );

end
