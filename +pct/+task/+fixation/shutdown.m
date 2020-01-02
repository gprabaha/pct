function shutdown(program)

close_window( program );
handle_cursor();
handle_keyboard();

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

function handle_keyboard()

try
  ListenChar( 0 );
catch err
  warning( err.message );
end

end