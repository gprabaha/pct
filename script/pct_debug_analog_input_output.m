ni_session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );

%%

t = tic();

ni_session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );

on = repmat( 5, ni_session.Rate, 1 );
off = zeros( ni_session.Rate, 1 );

queueOutputData( ni_session, [on; off]);
tic;
startBackground( ni_session );
toc;

toc( t );

%%

tic;
outputSingleScan( ni_session, 5 );
toc;
pause( 0.5 );
tic;
outputSingleScan( ni_session, 0 );
toc;
