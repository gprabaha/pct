function shutdown(program)

close_window( program );
handle_cursor();

end

function close_window(program)

try
  close( program.Value.window )
catch err
  warning( err.message );
end

end

function handle_cursor()

try
  ShowCursor();
catch err
  warning( err.message );
end

end