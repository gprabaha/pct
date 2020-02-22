function fixation_training_stage_key_listener(state, program)

if ( state(ptb.keys.up()) )
  program.Value.training_data.should_advance = true;
  
elseif ( state(ptb.keys.down()) )
  program.Value.training_data.should_revert = true;
end

end