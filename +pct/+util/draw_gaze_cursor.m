function draw_gaze_cursor(program)

gaze_cursor = program.Value.stimuli.gaze_cursor;
window = program.Value.window;
sampler = program.Value.sampler;

gaze_cursor.Position = [ sampler.X, sampler.Y ];
gaze_cursor.Position.Units = 'px';
draw( gaze_cursor, window );

end