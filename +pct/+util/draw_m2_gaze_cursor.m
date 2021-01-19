function draw_m2_gaze_cursor(program, is_debug)

m2_gaze_cursor = program.Value.stimuli.gaze_cursor_m2;
m2_sampler = program.Value.sampler_m2;
should_draw_m2 = program.Value.stimuli_setup.gaze_cursor_m2.visible;

if ( should_draw_m2 )
  pct.util.draw_one_gaze_cursor( program, m2_gaze_cursor, m2_sampler, is_debug );
end

end