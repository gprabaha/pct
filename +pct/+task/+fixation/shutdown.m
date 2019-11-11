function shutdown_fixation(program)

close_window( program );

end

function close_window(program)

try
  close( program.Value.window )
catch err
  warning( err.message );
end

end