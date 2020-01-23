function draw_gaze_cursor(program, is_debug)

gaze_cursor = program.Value.stimuli.gaze_cursor;
sampler = program.Value.sampler;

pixel_position = ptb.WindowDependent( [sampler.X, sampler.Y] );

if ( is_debug )
  task_window = program.Value.window;
  window = program.Value.debug_window;
  
  norm_pos = as_normalized( pixel_position, task_window );  
  position = ptb.WindowDependent( norm_pos, 'normalized' );
  
else
  position = pixel_position;
  window = program.Value.window;
end

gaze_cursor.Position = position;
draw( gaze_cursor, window );

end