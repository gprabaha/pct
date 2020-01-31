function pct_test_multi_reward(conf)

if ( nargin < 1 || isempty(conf) )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

ni_session = make_ni_daq_session();
ni_scan_output = make_ni_scan_output( ni_session );
reward_manager1 = make_ni_reward_manager( ni_scan_output, 1 );
reward_manager2 = make_ni_reward_manager( ni_scan_output, 2 );

key_timer = nan;
key_timer2 = nan;
key_timeout = 1.2;
reward_time = 0.5;

while ( ~ptb.util.is_esc_down() )
  if ( ptb.util.is_key_down(ptb.keys.space) && (isnan(key_timer) || toc(key_timer) > key_timeout) )
    trigger( reward_manager1, reward_time );
    key_timer = tic;
  elseif ( ptb.util.is_key_down(ptb.keys.r) && (isnan(key_timer2) || toc(key_timer2) > key_timeout) )
    trigger( reward_manager2, reward_time );
    key_timer2 = tic;
  end
  
  update( reward_manager1 );
  update( reward_manager2 );
  update( ni_scan_output );
end

end

function reward_manager = make_ni_reward_manager(ni_scan_output, channel_index)

reward_manager = ptb.signal.SingleScanOutputPulseManager( ni_scan_output, channel_index );

end

function ni_scan_output = make_ni_scan_output(ni_session)

ni_scan_output = ptb.signal.SingleScanOutput( ni_session );
ni_scan_output.PersistOutputValues = true;

end

function ni_session = make_ni_daq_session()

ni_session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

pct.util.add_reward_output_channels_to_ni_session( ni_session, ni_device_id );

end