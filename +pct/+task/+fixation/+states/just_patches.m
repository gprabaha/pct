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

pct.util.state_entry_timestamp( program, state );

num_patches = count_patches( program );
num_sources = 2;  % m1 and m2

state.UserData.agent_indices = [...
  pct.util.m1_agent_index(), pct.util.m2_agent_index() ...
];

% All patches remaining
state.UserData.num_patches_remaining = num_patches;
% No patches were acquired
state.UserData.patch_acquired = false( 1, num_patches );
% The IDs of the agent who acquired the patch.
state.UserData.patch_acquired_by = zeros( 1, num_patches );
% No patches were entered
state.UserData.mark_entered = false( num_sources, num_patches );
% No patches were exited
state.UserData.mark_exited = false( 1, num_patches );
% IDs of the agent who entered the patch.
state.UserData.entered_by = zeros( 1, num_patches );
% PatchInfo of successfully acquired patches.
state.UserData.acquired_patch_info = cell( 1, num_patches );

reset_targets( program );

handle_computer_generated_m2( program, state );

update_last_state( state, program );

end

function loop(state, program)

maybe_update_computer_generated_m2( program, state );

main_window = program.Value.window;

draw_patches( program, state, main_window );
draw_cursors( program, state );
flip( main_window );

debug_window_is_present = program.Value.debug_window_is_present;
if (debug_window_is_present)
  debug_window = program.Value.debug_window;
  
  draw_patches( program, state, debug_window );
  draw_debug_cursor( program );
  flip( debug_window );
end

check_targets( state, program );

% Exit if all patches were acquired.
% if ( state.UserData.num_patches_remaining == 0 )
m1_done_collecting = patch_acquired_count_criterion_met(program, state, pct.util.m1_agent_index());
m2_done_collecting = patch_acquired_count_criterion_met(program, state, pct.util.m2_agent_index());

if ( m1_done_collecting && m2_done_collecting )
  escape( state );
end

end

function exit(state, program)

pct.util.state_exit_timestamp( program, state );
register_acquired_patches( state, program.Value.data );

num_remaining = state.UserData.num_patches_remaining;

error_if_not_all_acquired = ...
  program.Value.config.STRUCTURE.error_if_not_all_patches_acquired;

% Default to reward.
next_state = 'juice_reward';

if ( num_remaining > 0 && error_if_not_all_acquired )
  % Some patches left, and we require all patches to be acquired -> error.
  next_state = 'error_penalty';
end

next( state, program.Value.states(next_state) );

end

function update_last_state(state, program)

program.Value.data.Value(end).last_state = 'jp';

end

function draw_patches(program, state, window)

% Initial assignments %

stimuli         = program.Value.current_patch_stimuli;
patch_targets   = { program.Value.current_patches.Target };
is_debug        = pct.util.is_debug( program );

% Operations %

for i = 1:numel(stimuli)
  stimulus = stimuli{i};
  draw( stimulus, window );

  if ( is_debug )
    draw( patch_targets{i}.Bounds, window );
  end
end

end

function draw_cursors(program, state)

% Initial assignment %

is_debug = pct.util.is_debug( program );


% Operations %

m1_still_working = ~patch_acquired_count_criterion_met(program, state, pct.util.m1_agent_index());
m2_still_working = ~patch_acquired_count_criterion_met(program, state, pct.util.m2_agent_index());

if ( m1_still_working )
  pct.util.draw_m1_gaze_cursor( program, is_debug );
end
if ( m2_still_working )
  pct.util.draw_m2_gaze_cursor( program, is_debug );
end

end

function draw_debug_cursor(program)

is_debug = true;
pct.util.draw_gaze_cursors( program, is_debug );

end

function tf = patch_acquired_count_criterion_met(program, state, agent_index)

patch_acquired_by = state.UserData.patch_acquired_by;
acquired_by_agent_only = patch_acquired_by == agent_index;
acquired_by_multiplie = patch_acquired_by == pct.util.cooperate_index();

num_acquired = sum( acquired_by_agent_only | acquired_by_multiplie );

patch_params = pct.util.get_patch_parameters( program );
tf = num_acquired >= patch_params.max_num_patches_acquireable_per_trial;

end

function tf = can_acquire_patch(patch_info, agent_index, program, state)

% Check whether the agent `agent_index` has already acquired more than 
% `max_num_patches_acquireable_per_trial`. If so, then the patch
% definitely cannot be acquired. Otherwise, if the patch is a self patch,
% check whether the patch's agent matches the agent given by `agent_index`.

if ( patch_acquired_count_criterion_met(program, state, agent_index) )
  tf = false;
  return
end

if ( strcmp(patch_info.Strategy, 'self') )
  tf = can_acquire_self( patch_info, agent_index );
else
  tf = true;
end

end

function tf = can_acquire_self(patch_info, source_index)

acq_by = patch_info.AcquirableBy;

assert( numel(acq_by) == 1 ...
  , 'Expected self patch to be acquireable by a single source, only.' );

if ( strcmp(acq_by, 'm1') )
  tf = source_index == pct.util.m1_agent_index();
  
elseif ( strcmp(acq_by, 'm2') )
  tf = source_index == pct.util.m2_agent_index();
  
else
  error( 'Unknown acquireable by id "%s".', acq_by );
end

end

function tf = can_acquire_cooperate_patch(patch_info, program, state, num_agents)

for i = 1:num_agents
  if ( ~can_acquire_patch(patch_info, i, program, state) )
    tf = false;
    return
  end
end

tf = true;

end

function acquire_patch(patch_info, state, program, patch_index, agent_index)

patch_acquired_timestamp( state, program, agent_index, patch_index );

patch_info.AcquiredByIndex = agent_index;

state.UserData.patch_acquired(patch_index) = true;
state.UserData.num_patches_remaining = ...
  state.UserData.num_patches_remaining - 1;
state.UserData.patch_acquired_by(patch_index) = agent_index;
state.UserData.acquired_patch_info{patch_index} = patch_info;

end

function check_targets(state, program)

patch_info = program.Value.current_patches;
stimuli = program.Value.current_patch_stimuli;
patches_acquired = state.UserData.patch_acquired;
agent_indices = state.UserData.agent_indices;

for i = 1:numel(patch_info)
  stimulus = stimuli{i};
  
  info = patch_info(i);
  target = info.Target;
  strategy = info.Strategy;
  
  in_bounds = target.IsInBounds;
  dur_met = target.IsDurationMet;
  num_agents = numel( in_bounds );
  
  for j = 1:num_agents
    if ( in_bounds(j) && ~state.UserData.mark_entered(j, i) && ~dur_met(j) )
      % Subject (j) entered this patch (i)
      patch_entry_timestamp( state, program, j, i );
      state.UserData.mark_entered(j, i) = true;
      state.UserData.entered_by(i) = j;
      % Assume subject (j) entered this patch via a saccade, in which case
      % we calculate a smoothed velocity over some number of preceding
      % position samples.
      update_saccade_velocity_histories( program, j );
      
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
          if ( dur_met(j) && can_acquire_patch(info, j, program, state) )
            agent_index = agent_indices(j);
            acquire_patch( info, state, program, i, agent_index );
            
            program.Value.data.Value(end).last_patch_type = 'self';
            if j==1
              program.Value.data.Value(end).last_agent = 'hitch';
            elseif j==2
              program.Value.data.Value(end).last_agent = 'computer_naive_random';
            end
            break;
          end
        end
        
      case 'compete'
        for j = 1:numel(dur_met)
          if ( dur_met(j) && can_acquire_patch(info, j, program, state) )
            agent_index = agent_indices(j);
            acquire_patch( info, state, program, i, agent_index );
            program.Value.data.Value(end).last_patch_type = 'compete';
            if j==1
              program.Value.data.Value(end).last_agent = 'hitch';
            elseif j==2
              program.Value.data.Value(end).last_agent = 'computer_naive_random';
            end
            break;
          end
        end
        
      case 'cooperate'
        if ( all(dur_met) && ...
             can_acquire_cooperate_patch(info, program, state, num_agents) )
          acquire_patch( info, state, program, i, pct.util.cooperate_index() );
          
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

function register_acquired_patches(state, data)

data.Value(end).just_patches.acquired_patches = state.UserData.acquired_patch_info;

end

function update_saccade_velocity_histories(program, agent_index)

if ( agent_index == pct.util.m1_agent_index() )
  history = program.Value.saccade_velocity_estimator_m1;
  
elseif ( agent_index == pct.util.m2_agent_index() )
  history = program.Value.saccade_velocity_estimator_m2;
  
else
  error( 'Unhandled agent index "%d".', agent_index );
end

register_saccade_end( history );

end

function maybe_update_computer_generated_m2(program, state)

generator_m2 = pct.util.maybe_get_computer_generated_m2( program );
if ( isempty(generator_m2) )
  return
end

patch_info = program.Value.current_patches;
patch_update( generator_m2, program, patch_info, state.UserData.patch_acquired );

end

function handle_computer_generated_m2(program, state)

generator_m2 = pct.util.maybe_get_computer_generated_m2( program );
if ( isempty(generator_m2) )
  return
end

patch_info = program.Value.current_patches;
initialize_saccades( generator_m2, patch_info, program, state.UserData.patch_acquired );

program.Value.data.Value(end).m2_saccade_time = ...
  generator_m2.get_current_saccade_time();

end