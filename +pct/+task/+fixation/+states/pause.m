function state = pause(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'pause';

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

timestamp_entry( state, program );

program.Value.pause_flag = true;

end

function loop(state, program)

quantity = program.Value.rewards.training/2;
inter_pulse_interval = 10;
reward_timer = state.UserData.reward_timer;
pulse_duration = quantity;

if ( isnan(reward_timer) || ...
     toc(reward_timer) > pulse_duration + inter_pulse_interval )
  pct.util.deliver_reward( program, 1, quantity );
  state.UserData.reward_timer = tic();
  state.UserData.num_pulses = state.UserData.num_pulses + 1;
end

end

function exit(state, program)

states = program.Value.states;
timestamp_exit( state, program );
next( state, states('new_trial') );

end

function timestamp_entry(state, program)

program.Value.data.Value(end).(state.Name).entry_time = elapsed( program.Value.task );

end

function timestamp_exit(state, program)

program.Value.data.Value(end).(state.Name).exit_time = elapsed( program.Value.task );

end