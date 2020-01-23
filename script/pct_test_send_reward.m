function pct_test_send_reward(program)

reward_manager = program.Value.ni_reward_manager;

if ( isempty(reward_manager) )
  return
end

trigger( reward_manager, 0.3 );

% ni_session = program.Value.ni_session;
% 
% if ( isempty(ni_session) )
%   return
% end
% 
% on = repmat( 5, ni_session.Rate, 1 );
% off = zeros( ni_session.Rate, 1 );
% 
% queueOutputData( ni_session, [on; off]);

end