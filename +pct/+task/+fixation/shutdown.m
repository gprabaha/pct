function shutdown(program)

close_window( program );
close_arduino( program );
handle_cursor();
handle_keyboard();

[local_path, remote_path] = save_paths( program );
save_task_data( program, local_path, remote_path );

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

function [local_path, remote_path] = save_paths(program)

if ( isfield(program.Value, 'data_directory') )
  local_path = program.Value.data_directory;
  
else
  rep_path = repdir;
  local_path = fullfile( rep_path, 'pct/+pct/+data/+training/' );
  
  warning( ['Expected to find a "data_directory" field in the program data ' ...
    , ' but could not; using an alternative path: %s.'], local_path );
end

remote_path = program.Value.config.PATHS.remote;

end

function filename = make_filename()

filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-pct-training-data'];

end

function save_task_data(program, local_path, remote_path)

if ( ~program.Value.interface.save_data )
  return
end

try
  shared_utils.io.require_dir( local_path );
  if ( ~isempty(remote_path) )
    shared_utils.io.require_dir( remote_path );
  end

  program_data = program.Value;
  
  data_filename = make_filename();
  local_filepath = fullfile( local_path, data_filename );
  save( local_filepath, 'program_data' );
  
  if ( ~isempty(remote_path) )
    remote_filepath = fullfile( remote_path, data_filename );
    save( remote_filepath, 'program_data' );
  end
  
catch err
  warning( err.message );
end

end