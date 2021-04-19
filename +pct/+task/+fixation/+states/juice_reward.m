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

pre_reward_delay = calculate_pre_reward_delay( program );

state.UserData.reward_timer_m1 = nan;
state.UserData.reward_timer_m2 = nan;
state.UserData.num_pulses_m1 = 0;
state.UserData.num_pulses_m2 = 0;
state.UserData.reward_delay_timer = tic;
state.UserData.reward_delay = pre_reward_delay;

program.Value.data.Value(end).juice_reward.pre_reward_delay = pre_reward_delay;

end

function loop(state, program)

% Initial assignments %

quantity                = program.Value.rewards.training;
inter_pulse_interval    = 5e-2;  % 10ms;
patch_sequence_index    = program.Value.current_patch_sequence_index;
num_trials_in_sequence  = 1;
reward_timer_m1         = state.UserData.reward_timer_m1;
reward_timer_m2         = state.UserData.reward_timer_m2;

% Operations %

num_collected_patches_m1 = num_acquired_patches_in_sequence( ...
  program, pct.util.m1_agent_index(), num_trials_in_sequence );

num_collected_patches_m2 = num_acquired_patches_in_sequence( ...
  program, pct.util.m2_agent_index(), num_trials_in_sequence );

pulse_duration = quantity;

if ( toc(state.UserData.reward_delay_timer) > state.UserData.reward_delay )
  reward_timer_dur = pulse_duration + inter_pulse_interval;
  
  deliver_m1 = should_deliver_reward(...
    state.UserData.num_pulses_m1, num_collected_patches_m1, reward_timer_m1, reward_timer_dur );
  
  deliver_m2 = should_deliver_reward(...
    state.UserData.num_pulses_m2, num_collected_patches_m2, reward_timer_m2, reward_timer_dur );
  
  if ( deliver_m1 )
    pct.util.log( 'Delivering reward for m1', pct.util.LogInfo('juice_reward') );
     
    pct.util.deliver_reward( program, 1, quantity );
    state.UserData.reward_timer_m1 = tic();
    state.UserData.num_pulses_m1 = state.UserData.num_pulses_m1 + 1;
  end
  if ( deliver_m2 )
    pct.util.log( 'Delivering reward for m2', pct.util.LogInfo('juice_reward') );
     
    pct.util.deliver_reward( program, 2, quantity );
    state.UserData.reward_timer_m2 = tic();
    state.UserData.num_pulses_m2 = state.UserData.num_pulses_m2 + 1;
  end
end

% Escape state if not the last choice in the trial sequence
if ( patch_sequence_index ~= num_trials_in_sequence )
  escape( state );
end

end

function exit(state, program)

pct.util.state_exit_timestamp( program, state );

states = program.Value.states;
next( state, states('iti') );

end

function tf = should_deliver_reward(num_pulses, num_patches, reward_timer, pulse_dur)

tf = num_pulses < num_patches && ...
     (isnan(reward_timer) || toc(reward_timer) > pulse_dur);

end

function num_acquired = num_acquired_patches_in_sequence(program, agent_index, num_trials_in_sequence)

num_acquired = 0;

patch_sequence_index = program.Value.current_patch_sequence_index;

if ( patch_sequence_index ~= num_trials_in_sequence )
  % Only give reward on the last choice in the trial sequence.
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
      reward_count = maybe_acquired.RewardCount;
      
      if ( acquired_by_ind == agent_index || ...
           acquired_by_ind == pct.util.cooperate_index() )
         num_acquired = num_acquired + reward_count;
      end
    end
  end
end

end

function delay = calculate_pre_reward_delay(program)

delay_mean = program.Value.config.TIMINGS.time_in.pre_reward_delay_mean;
delay_span = program.Value.config.TIMINGS.time_in.pre_reward_delay_variation;

delay_variation = (rand * 2 - 1) * delay_span;
delay = max( 0, delay_mean + delay_variation );

end