function maybe_go_to_pause_state(state, program)

if ( state(ptb.keys.p()) )
  pct.util.log( 'Going to pause state.', pct.util.LogInfo('pause_state') );
  program.Value.go_to_pause_state_override = true;
end

end