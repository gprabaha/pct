
function close_ports()

%	CLOSE_PORTS -- Close open serial ports.

ports = instrfind;
if ( isempty(ports) ), return; end;
fclose( ports );

end