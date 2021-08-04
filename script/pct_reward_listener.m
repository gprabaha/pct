function pct_reward_listener(varargin)

defaults = struct();
defaults.rwd_amount_s = 1;
defaults.rwd_key_timeout = 0.5;
defaults.rwd_channel = 1;
defaults.rwd_key = ptb.keys.r();
defaults.port = 'COM3';
defaults.channels = { 'A' };
defaults.dummy = false;

params = shared_utils.general.parsestruct( defaults, varargin );

channels = params.channels;
rwd_manager = serial_comm.SerialManager( params.port, struct(), channels );
if ( ~params.dummy )
  start( rwd_manager );
end

cleanup = onCleanup( @() maybe_stop(rwd_manager) );

rwd_key_timer = nan;
rwd_key_timeout = params.rwd_key_timeout;
rwd_amount_s = params.rwd_amount_s;
rwd_channel = params.rwd_channel;
rwd_key = params.rwd_key;

while ( ~ptb.util.is_esc_down() )
  update( rwd_manager );
  
  if ( ptb.util.is_key_down(rwd_key) )
    if ( isnan(rwd_key_timer) || toc(rwd_key_timer) > rwd_key_timeout )
      fprintf( '\n Reward.' );
      if ( ~params.dummy )
        reward( rwd_manager, rwd_channel, rwd_amount_s * 1e3 ); % to ms
      end
      rwd_key_timer = tic;
    end
  end
end

end

function maybe_stop(manager)

if ( ~isempty(manager) && manager.is_started )
  stop( manager );
end

end