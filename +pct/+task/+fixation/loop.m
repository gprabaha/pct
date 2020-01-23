function loop(task, program)

if ( ~isempty(program.Value.ni_scan_input) )
  update( program.Value.ni_scan_input );
end

update( program.Value.updater );

if ( pct.util.is_debug(program) )
  debug_update_loop_frame_time( program );
end

if ( ~program.Value.interface.use_mouse )
    sync_eyelink( task, program );
end

end

function sync_eyelink(task, program)

sync_info = program.Value.tracker_sync;
should_send_sync_pulse = isnan( sync_info.timer ) || ...
    toc( sync_info.timer ) >= sync_info.tracker_sync_interval;

if ( should_send_sync_pulse )
    tracker = program.Value.tracker;
    send_message( tracker, 'sync' );
    mat_time = elapsed( task );
    
    sync_info.times(sync_info.next_iteration) = mat_time;
    sync_info.next_iteration = sync_info.next_iteration + 1;
    sync_info.timer = tic();
    
    program.Value.tracker_sync = sync_info;
end

end

function debug_update_loop_frame_time(program)

if ( ~isfield(program.Value.debug, 'task_loop_frame_timer') )
  program.Value.debug.task_loop_frame_timer = ptb.FrameTimer();
else
  update( program.Value.debug.task_loop_frame_timer );
end

end