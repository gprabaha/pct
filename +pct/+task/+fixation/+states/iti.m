function state = iti(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'iti';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(~, program)

flip( program.Value.window );
if ( program.Value.debug_window_is_present )
  flip( program.Value.debug_window );
end

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );

end