function run(varargin)

program = pct.task.fixation.setup( varargin{:} );

try
  pct.task.run_fixation( program );
catch err
  warning( err.message );
end

delete( program );

end