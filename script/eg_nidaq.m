s = daq.createSession( 'ni' );

port = 'Dev1';

addAnalogInputChannel( s, port, 0, 'Voltage' );
addAnalogInputChannel( s, port, 1, 'Voltage' );
addAnalogOutputChannel( s, port, 0, 'Voltage' );

%%

t = tic;

while ( ~ptb.util.is_esc_down() )
  data = inputSingleScan( s )
end

%%

on = repmat( 5, s.Rate/4  , 1 );
off = zeros( s.Rate/4 * 3, 1 );

queueOutputData(s, [on; off]);
s.startForeground;