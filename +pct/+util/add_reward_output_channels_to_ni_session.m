function add_reward_output_channels_to_ni_session(ni_session, ni_device_id)

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );
addAnalogOutputChannel( ni_session, ni_device_id, 1, 'Voltage' );

end