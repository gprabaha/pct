function start(varargin)

program = pct.task.fixation.setup( varargin{:} );
err = [];

try
  pct.task.fixation.run( program );
catch err
end

delete( program );

if ( ~isempty(err) )
  rethrow( err );
end

end