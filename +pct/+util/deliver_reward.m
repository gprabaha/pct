function deliver_reward(program, channel, for_time)

ni_reward_manager = program.Value.ni_reward_manager;
arduino_reward_manager = program.Value.arduino_reward_manager;

if ( ~isempty(ni_reward_manager) )
  trigger( ni_reward_manager, for_time );
  
elseif ( ~isempty(arduino_reward_manager) )
  reward( arduino_reward_manager, channel, for_time * 1e3 ); % to ms
end

end