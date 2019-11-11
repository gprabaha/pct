
function err = start(conf)

%   START -- Attempt to setup and run the task.
%
%     OUT:
%       - `err` (double, MException) -- 0 if successful; otherwise, the
%         raised MException, if setup / run fails.

if ( nargin < 1 || isempty(conf) )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

try
  opts = pct.task.setup( conf );
catch err
  pct.task.cleanup();
  pct.util.print_error_stack( err );
  return;
end

try
  err = 0;
  pct.task.run( opts );
  pct.task.cleanup();
catch err
  pct.task.cleanup();
  pct.util.print_error_stack( err );
end

end