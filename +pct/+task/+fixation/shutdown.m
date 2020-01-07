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

rep_path = repdir;
path = [rep_path 'pct/+pct/+data/+training/'];
which path

end

function save_data(program, path)

try
  program_data = program.Value;
  data_filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-pct-training-data'];
  save([path data_filename], 'program_data');
catch err
  warning( err.message )
end

end