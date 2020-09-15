function shutdown(program)

close_window( program );
close_arduino( program );
handle_cursor();
handle_keyboard();

path = save_path();
save_task_data( program, path );

end

function close_arduino(program)

try
  reward_manager = program.Value.arduino_reward_manager;
  
  if ( ~isempty(reward_manager) )
    close( reward_manager );
  end
  
catch err
  warning( err.message );
end

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
path = fullfile( rep_path, 'pct/+pct/+data/+training/' );
which path

end

function save_task_data(program, path)

if( program.Value.interface.save_data )
  try
    program_data = program.Value;
    data_filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-pct-training-data'];
    save([path data_filename], 'program_data');
    path_dropbox = 'C:\Users\changlab\Dropbox (ChangLab)\prabaha_changlab\pct-training-hitch\comp-coop\';
    save([path_dropbox data_filename], 'program_data');
  catch err
    warning( err.message );
  end
end

end