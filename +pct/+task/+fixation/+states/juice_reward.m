function state = juice_reward(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'juice_reward';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

pct.util.state_entry_timestamp( program, state );

flip( program.Value.window );
debug_window_is_present = program.Value.debug_window_is_present;

if (debug_window_is_present)
  flip( program.Value.debug_window );
end
give_juice_reward( program );

state.UserData.reward_timer = nan;
state.UserData.num_pulses = 0;

end

function loop(state, program)

quantity = program.Value.rewards.training;
inter_pulse_interval = 5e-2;  % 10ms;
num_collected_patches = sum( ~isnan( program.Value.data.Value(end).just_patches.patch_acquired_times ) );
reward_timer = state.UserData.reward_timer;
pulse_duration = quantity;

if ( state.UserData.num_pulses < num_collected_patches )
  if ( isnan(reward_timer) || ...
       toc(reward_timer) > pulse_duration + inter_pulse_interval )
    pct.util.deliver_reward( program, 1, quantity );
    state.UserData.reward_timer = tic();
    state.UserData.num_pulses = state.UserData.num_pulses + 1;
  end
end

end

function exit(state, program)

pct.util.state_exit_timestamp( program, state );

states = program.Value.states;
next( state, states('iti') );

end

function give_juice_reward(program)

m1_quantity = calculate_m1_reward( program );

if ( m1_quantity > 0 )  
  pct.util.deliver_reward( program, 1, m1_quantity );
end

end

function num_acquired = num_acquired_patches_in_sequence(program, agent_index)

num_acquired = 0;

patch_sequence_index = program.Value.current_patch_sequence_index;
num_trials_in_sequence = 2;

if ( patch_sequence_index ~= num_trials_in_sequence )
  % Only give reward on the last choice in the sequence.
  return
end

data = program.Value.data.Value;
assert( numel(data) >= num_trials_in_sequence ...
  , 'Expected at least %d preceding trials.', num_trials_in_sequence );

for i = 1:num_trials_in_sequence
  trial_data = data(end-(i-1));
  acquired_patches = trial_data.just_patches.acquired_patches;
  
  for j = 1:numel(acquired_patches)
    maybe_acquired = acquired_patches{j};
    
    if ( ~isempty(maybe_acquired) )
      acquired_by_ind = maybe_acquired.AcquiredByIndex;
      
      if ( acquired_by_ind == agent_index || ...
           acquired_by_ind == pct.util.cooperate_index() )
         num_acquired = num_acquired + 1;
      end
    end
  end
end

end

function quantity = calculate_m1_reward(program)

num_acquired = num_acquired_patches_in_sequence( program, pct.util.m1_agent_index() );
per_patch_quantity = program.Value.rewards.training;
quantity = per_patch_quantity * num_acquired;

end

function quantity = calculate_m2_reward(program)

num_acquired = num_acquired_patches_in_sequence( program, pct.util.m2_agent_index() );
per_patch_quantity = program.Value.rewards.training;
quantity = per_patch_quantity * num_acquired;

end