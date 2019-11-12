function state = present_patches(program, conf)

time_in = conf.TIMINGS.time_in;

state = ptb.State();
state.Name = 'present_patches';

state.Duration = time_in.(state.Name);

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

end

function loop(state, program)

draw_targets( program );
draw_cursor( program );
flip( program.Value.window );

check_targets( state, program );

end

function exit(state, program)

next( state, program.Value.states('new_trial') );

end

function draw_targets(program)

end

function draw_cursor(program)

pct.util.draw_gaze_cursor( program );

end

function check_targets(state, program)

end