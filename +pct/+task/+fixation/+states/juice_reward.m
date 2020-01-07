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
give_juice_reward( program );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );

end

function give_juice_reward(program)

reward_manager = program.Value.arduino_reward_manager;

if ( isempty(reward_manager) )
    return;
end

quantity = program.Value.rewards.training;
reward( reward_manager, 1, quantity );

end