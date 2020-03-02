function draw_gaze_cursor(program, is_debug)

m1_gaze_cursor = program.Value.stimuli.gaze_cursor;
m1_sampler = program.Value.sampler;

m2_gaze_cursor = program.Value.stimuli.gaze_cursor_m2;
m2_sampler = program.Value.sampler_m2;
should_draw_m2 = program.Value.stimuli_setup.gaze_cursor_m2.visible;

draw_one_cursor( program, m1_gaze_cursor, m1_sampler, is_debug );

if ( should_draw_m2 )
  draw_one_cursor( program, m2_gaze_cursor, m2_sampler, is_debug );
end

end

function draw_one_cursor(program, gaze_cursor, sampler, is_debug)

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