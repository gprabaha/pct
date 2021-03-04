function pause_state_key_listener(state, program)

if ( state(ptb.keys.p()) )
  pct.util.log( 'Pause state key flag set.', pct.util.LogInfo('pause_state') );
  program.Value.pause_state_key_flag = true;
end

end