function state = iti(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'iti';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

state_time = get_time_in_state( program );
state.Duration = state_time;

flip( program.Value.window );
if ( program.Value.debug_window_is_present )
  flip( program.Value.debug_window );
end

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );

end

function state_time = get_time_in_state(program)

time_in = program.Value.config.TIMINGS.time_in;
seq_index = pct.util.current_patch_sequence_index( program );

if ( seq_index == 1 )
  state_time = time_in.iti_patch_sequence_1;
  
elseif ( seq_index == 2 )
  state_time = time_in.iti_patch_sequence_2;
  
else
  error( 'Unhandled patch sequence index %d.', seq_index );
end

end