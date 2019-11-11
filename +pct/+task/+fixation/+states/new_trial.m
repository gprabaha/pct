function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end