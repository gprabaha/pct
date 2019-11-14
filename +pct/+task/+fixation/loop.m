function loop(task, program)

update( program.Value.updater );

if ( pct.util.is_debug(program) )
  debug_update_loop_frame_time( program );
end

end

function debug_update_loop_frame_time(program)

if ( ~isfield(program.Value.debug, 'task_loop_frame_timer') )
  program.Value.debug.task_loop_frame_timer = ptb.FrameTimer();
else
  update( program.Value.debug.task_loop_frame_timer );
end

end