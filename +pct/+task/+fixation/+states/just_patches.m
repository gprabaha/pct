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
num_sources = 2;  % m1 and m2

% All patches remaining
state.UserData.num_patches_remaining = num_patches;
% No patches were acquired
state.UserData.patch_acquired = false( 1, num_patches );
% The IDs of the agent who acquired the patch.
state.UserData.patch_acquired_by = zeros( num_sources, num_patches );
% No patches were entered
state.UserData.mark_entered = false( num_sources, num_patches );
% No patches were exited
state.UserData.mark_exited = false( 1, num_patches );
% IDs of the agent who entered the patch.
state.UserData.entered_by = zeros( 1, num_patches );

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

% Check with Nick of this is the right way of exiting.
if ( state.UserData.num_patches_remaining < count_patches(program) )
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

function tf = can_acquire_self(patch_info, source_index)

acq_by = patch_info.AcquirableBy;

assert( numel(acq_by) == 1 ...
  , 'Expected self patch to be acquireable by a single source, only.' );

if ( strcmp(acq_by, 'm1') )
  tf = source_index == 1;
  
elseif ( strcmp(acq_by, 'm2') )
  tf = source_index == 2;
  
else
  error( 'Unknown acquireable by id "%s".', acq_by );
end

end

function acquire_patch(state, program, patch_index, source_index)

patch_acquired_timestamp( state, program, source_index, patch_index );
state.UserData.patch_acquired(patch_index) = true;
state.UserData.num_patches_remaining = ...
  state.UserData.num_patches_remaining - 1;
state.UserData.patch_acquired_by(patch_index) = source_index;

end

function check_targets(state, program)

patch_info = program.Value.current_patches;
stimuli = program.Value.current_patch_stimuli;
patches_acquired = state.UserData.patch_acquired;

for i = 1:numel(patch_info)
  stimulus = stimuli{i};
  
  info = patch_info(i);
  target = info.Target;
  strategy = info.Strategy;
  
  in_bounds = target.IsInBounds;
  dur_met = target.IsDurationMet;
  
  for j = 1:numel(in_bounds)
    if ( in_bounds(j) && ~state.UserData.mark_entered(j, i) && ~dur_met(j) )
      % Subject (j) entered this patch (i)
      patch_entry_timestamp( state, program, j, i );
      state.UserData.mark_entered(j, i) = true;
      state.UserData.entered_by(i) = j;
      
    elseif ( state.UserData.mark_entered(j, i) && ~in_bounds(j) && ~dur_met(j) )
      % Subject (j) exited this patch (i)
      patch_exit_timestamp( state, program, j, i );
      state.UserData.mark_entered(j, i) = false;
    end
  end
  
  if ( ~patches_acquired(i) )
    switch ( strategy )
      case 'self'
        for j = 1:numel(dur_met)
          if ( dur_met(j) && can_acquire_self(info, j) )
            acquire_patch( state, program, i, j );
            program.Value.data.Value(end).last_patch_type = 'self';
            if j==1
              program.Value.data.Value(end).last_agent = 'hitch';
            elseif j==2
              program.Value.data.Value(end).last_agent = 'm2_cursor';
            end
            break;
          end
        end
        
      case 'compete'
        for j = 1:numel(dur_met)
          if ( dur_met(j) )
            acquire_patch( state, program, i, j );
            program.Value.data.Value(end).last_patch_type = 'compete';
            if j==1
              program.Value.data.Value(end).last_agent = 'hitch';
            elseif j==2
              program.Value.data.Value(end).last_agent = 'm2_cursor';
            end
            break;
          end
        end
        
      case 'cooperate'
        if ( all(dur_met) )
          acquire_patch( state, program, i, j );
          
          % Add a patch acquired time stamp for each subject that is not
          % subject `j`
          remaining_subjects = setdiff( 1:numel(in_bounds), j );
          
          for k = 1:numel(remaining_subjects)
            patch_acquired_timestamp( state, program, remaining_subjects(k), i );
          end
          
          program.Value.data.Value(end).last_patch_type = 'cooperate';
          program.Value.data.Value(end).last_agent = 'both';
        end
        
      otherwise
        error( 'Unhandled strategy "%s".', strategy );
    end
  end
  
  if ( patches_acquired(i) )
    stimulus.FaceColor = [0, 0, 0];
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

function patch_entry_timestamp( state, program, subject_id, patch_id )

program.Value.data.Value(end).(state.Name).patch_entry_times{subject_id, patch_id} = ...
    [program.Value.data.Value(end).(state.Name).patch_entry_times{subject_id, patch_id} ...
    elapsed( program.Value.task )];

end

function patch_exit_timestamp( state, program, subject_id, patch_id )

program.Value.data.Value(end).(state.Name).patch_exit_times{subject_id, patch_id} = ...
    [program.Value.data.Value(end).(state.Name).patch_exit_times{subject_id, patch_id} ...
    elapsed( program.Value.task )];

end

function patch_acquired_timestamp( state, program, subject_id, patch_id )

program.Value.data.Value(end).(state.Name).patch_acquired_times(subject_id, patch_id) = ...
    elapsed( program.Value.task );

end

function handle_computer_generated_m2(program)

interface = program.Value.interface;

if ( ~interface.has_m2 || ~interface.m2_is_computer )
  return
end

generator_m2 = program.Value.generator_m2;

patch_info = program.Value.current_patches;
initialize( generator_m2, patch_info, program );

program.Value.data.Value(end).m2_saccade_time = ...
  generator_m2.get_current_saccade_time();

end
