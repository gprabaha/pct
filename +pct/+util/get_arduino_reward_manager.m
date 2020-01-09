function comm = get_arduino_reward_manager(conf)

if ( nargin < 1 )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

port = conf.SERIAL.port;
messages = struct();
channels = conf.SERIAL.channels;

comm = serial_comm.SerialManager( port, messages, channels );

end