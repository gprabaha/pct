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

quantity = program.Value.rewards.training;

just_patches_trial_data = program.Value.data.Value(end).just_patches;
patch_acquired_times = just_patches_trial_data.patch_acquired_times;

if ( ~isempty(patch_acquired_times) )
  m1_acquired_times = patch_acquired_times(1, :);
  % The number of patches m1 acquired is the number of patch acquired
  % time stamps that are valid (i.e., not NaN).
  num_m1_acquired_patches = sum( ~isnan(m1_acquired_times) );
else
  num_m1_acquired_patches = 0;
end

if ( num_m1_acquired_patches > 0 )
  pct.util.deliver_reward( program, 1, quantity * num_m1_acquired_patches );
  
  % Adding lines to deliver multiple pulses for patches collected instead
  % of one big pulse
  
%   patches_to_reward = num_m1_acquired_patches;
%   for pulse_ind = 1:patches_to_reward
%     if pulse_ind > 1
%       pause(0.2);
%     end
%     pct.util.deliver_reward( program, 1, quantity );
%   end
end

end