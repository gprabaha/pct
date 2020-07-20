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
WaitSecs(0.2)
give_juice_reward( program );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );


end

function give_juice_reward(program)

quantity = program.Value.rewards.training;
% Check this with Nick
collected = sum( ~isnan( program.Value.data.Value(end).just_patches.patch_acquired_times ) );
pct.util.deliver_reward( program, 1, collected*quantity );

end