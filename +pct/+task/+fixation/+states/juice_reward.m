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

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );
give_juice_reward( program );

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
end

end