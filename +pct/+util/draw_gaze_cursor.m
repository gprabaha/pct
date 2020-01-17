function draw_gaze_cursor(program, is_debug)

gaze_cursor = program.Value.stimuli.gaze_cursor;
if ( is_debug )
  window = program.Value.debug_window;
else
  window = program.Value.window;
end
sampler = program.Value.sampler;

gaze_cursor.Position = [ sampler.X, sampler.Y ];
gaze_cursor.Position.Units = 'px';
draw( gaze_cursor, window );

end