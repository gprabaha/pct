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

flip( program.Value.window );
debug_window_is_present = program.Value.debug_window_is_present;

if (debug_window_is_present)
  flip( program.Value.debug_window );
end

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

states = program.Value.states;
next( state, states('new_trial') );

end