function modify_saccade_velocity_key_listener(state, program)

generator = program.Value.generator_m2;

if ( state(ptb.keys.up()) )
  % Faster.
  increment_saccade_speed( generator, 1 );
  
elseif ( state(ptb.keys.down()) )
  % Slower.
  increment_saccade_speed( generator, -1 );
end

end