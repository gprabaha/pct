function trigger_key_press_reward(state, program)

if ( state(ptb.keys.r()) )
  quantity = program.Value.config.REWARDS.key_press;
  pct.util.deliver_reward( program, 1, quantity );
  
  msg = sprintf( 'Delivering reward (%0.2f)', quantity );
  pct.util.log( msg, pct.util.LogInfo('reward') );
end

end