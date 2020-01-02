function shutdown(program)

close_window( program );
handle_cursor();
handle_keyboard();
path = save_path();
save_data( program, path );

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

function path = save_path()

path = 'pct.data.training';

end

function save_data(program, path)

try
  program.Value.data.Config = pct.config.load;
  data = program.Value.data;
  data_filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-pct-data'];
  save([path data_filename], data);
catch err
  warning( err.message )
end

end