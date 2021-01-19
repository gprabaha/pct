function state = error_penalty(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'error_penalty';

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

pct.util.state_entry_timestamp( program, state );

end

function loop(state, program)

end

function exit(state, program)

pct.util.state_exit_timestamp( program, state );

states = program.Value.states;
next( state, states('iti') );

end