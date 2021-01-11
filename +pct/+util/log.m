function log(varargin)

persistent logger;

narginchk( 2, 2 );

if ( isa(varargin{1}, 'double') )
  % Set the global logger.
  cmd = varargin{1};
  validateattributes( cmd, {'double'}, {'scalar', 'integer'}, mfilename, 'command' );
  
  switch ( cmd )
    case 0
      validateattributes( varargin{2}, {'pct.util.Logger'}, {}, mfilename, 'logger' );
      logger = varargin{2};
      
    otherwise
      error( 'Unhandled command "%d".', cmd );
  end
else
  % Log through the global logger.
  assert( ~isempty(logger) && isvalid(logger), 'No Logging instance has been set.' );
  logger.log( varargin{:} );  
end

end