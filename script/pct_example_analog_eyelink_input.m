function pct_example_analog_eyelink_input()

session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

x_channel = 'ai0';
y_channel = 'ai1';

channels = { x_channel, y_channel };
for i = 1:numel(channels)
  addAnalogInputChannel( session, ni_device_id, channels{i}, 'Voltage' );
end

scan_input = ptb.signal.SingleScanInput( session );
source1 = make_source1( scan_input );

while ( ~ptb.util.is_esc_down() )
  update( scan_input );
  update( source1 );
  
  disp( [source1.X, source1.Y] );
end

end

function source1 = make_source1(scan_input)

source1 = ptb.sources.XYAnalogInput( scan_input );
source1.CalibrationRect = [ 0, 0, 1024, 768 ];
source1.OutputVoltageRange = [ -5, 5 ];
source1.ChannelMapping = [1, 2];
source1.CalibrationRectPaddingFract = [0.2, 0.2];

end