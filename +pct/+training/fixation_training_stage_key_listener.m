function fixation_training_stage_key_listener(state, program)

if ( state(ptb.keys.up()) )
  program.Value.training_data.should_advance = true;
  
elseif ( state(ptb.keys.down()) )
  program.Value.training_data.should_revert = true;
end

if ( state(ptb.keys.right()) )
  program.Value.training_data.mean_m2_saccade_velocity_shift_direction = 1;
  
elseif ( state(ptb.keys.left()) )
  program.Value.training_data.mean_m2_saccade_velocity_shift_direction = -1;
end

end