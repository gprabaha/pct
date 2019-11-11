function start(varargin)

program = pct.task.fixation.setup( varargin{:} );

try
  pct.task.fixation.run( program );
catch err
  warning( err.message );
end

delete( program );

end