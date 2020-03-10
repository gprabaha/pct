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

% All patches remaining
state.UserData.num_patches_remaining = count_patches( program );
% No patches were acquired
state.UserData.patch_elapsed_state = false( 1, count_patches(program) );
% No patches were entered
state.UserData.mark_entered = false( 1, count_patches( program ) );
% No patches were exited
state.UserData.mark_exited = false( 1, count_patches( program ) );

reset_targets( program );

handle_computer_generated_m2( program );

timestamp_entry( state, program );
update_last_state( state, program );

end

function loop(state, program)

draw_targets( program );
draw_cursor( program );
flip( program.Value.window );

debug_window_is_present = program.Value.debug_window_is_present;
if (debug_window_is_present)
  draw_debug_targets( program );
  draw_debug_cursor( program );
  flip( program.Value.debug_window );
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

function draw_targets(program)

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

function draw_debug_targets(program)

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

function check_targets(state, program)

patch_targets = program.Value.patch_targets;
stimuli = program.Value.stimuli;


for i = 1:numel(patch_targets)
  stim_name = pct.util.nth_patch_stimulus_name( i );
  stimulus = stimuli.(stim_name);
  
  if ( patch_targets{i}.IsInBounds && ~state.UserData.mark_entered(i) && ~patch_targets{i}.IsDurationMet )
    % Entered one of the patches
    patch_entry_timestamp( state, program, i );
    state.UserData.mark_entered(i) = true;
  
  elseif ( state.UserData.mark_entered(i) && ~patch_targets{i}.IsInBounds && ~patch_targets{i}.IsDurationMet )
    % Exited one of the patches before duration was met
    patch_exit_timestamp( state, program, i );
    state.UserData.mark_entered(i) = false;
  end
    
  if ( patch_targets{i}.IsDurationMet )
    stimulus.FaceColor = [0, 0, 0];
    
    if ( ~state.UserData.patch_elapsed_state(i) )
      % The patch has already been acquired
      patch_acquired_timestamp( state, program, i );
      state.UserData.patch_elapsed_state(i) = true;
      state.UserData.num_patches_remaining = state.UserData.num_patches_remaining - 1;
    end
  end
end

end

function reset_targets(program)

num_patches = count_patches( program );
patch_targets = program.Value.patch_targets;

for i = 1:numel(patch_targets)
  reset( patch_targets{i} );
end

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

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

initialize( program.Value.generator_m2, program );

end
