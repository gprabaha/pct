function draw_m1_gaze_cursor(program, is_debug)

m1_gaze_cursor = program.Value.stimuli.gaze_cursor;
m1_sampler = program.Value.sampler;
pct.util.draw_one_gaze_cursor( program, m1_gaze_cursor, m1_sampler, is_debug );

end