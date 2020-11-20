function shutdown(program)

close_window( program );
close_arduino( program );
delete_trackers( program );

handle_cursor();
handle_keyboard();

[local_path, remote_path] = save_paths( program );
save_task_data( program, local_path, remote_path );

end

function delete_trackers(program)

if ( isfield(program.Value, 'tracker') )
  delete_tracker( program.Value.tracker );
end
if ( isfield(program.Value, 'tracker_m2') )
  delete_tracker( program.Value.tracker_m2 );
end

end

function delete_tracker(tracker)

try
  delete( tracker );
catch err
  warning( err.message );
end

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

[~, session_dir] = fileparts( local_path );
remote_path = fullfile( program.Value.config.PATHS.remote, session_dir );

end

function filename = make_filename()

filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-pct-training-data'];

end

function maybe_copy_edf_file(src_path, dest_path, filename)

src_file = fullfile( src_path, filename );

if ( shared_utils.io.fexists(src_file) )
  dest_file = fullfile( dest_path, filename );
  
  try
    copyfile( src_file, dest_file );
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
    
    if ( ~isempty(program.Value.edf_filename_m1) )
      maybe_copy_edf_file( local_path, remote_path, program.Value.edf_filename_m1 );
    end
    if ( ~isempty(program.Value.edf_filename_m2) )
      maybe_copy_edf_file( local_path, remote_path, program.Value.edf_filename_m2 );
    end
  end
  
catch err
  warning( err.message );
end

end