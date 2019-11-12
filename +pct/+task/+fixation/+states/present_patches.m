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

% All patches remaining
state.UserData.num_patches_remaining = count_patches( program );
% No patches were acquired
state.UserData.patch_elapsed_state = false( 1, count_patches(program) );

reset_targets( program );
position_stimuli( state, program );

end

function loop(state, program)

draw_targets( program );
draw_cursor( program );
flip( program.Value.window );

check_targets( state, program );

% Exit if all patches were acquired.
if ( state.UserData.num_patches_remaining == 0 )
  escape( state );
end

end

function exit(state, program)

next( state, program.Value.states('new_trial') );

end

function draw_targets(program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
window = program.Value.window;
patch_targets = program.Value.patch_targets;

is_debug = program.Value.interface.is_debug;

for i = 1:num_patches
  stimulus = stimuli.(pct.util.nth_patch_stimulus_name(i));
  draw( stimulus, window );
  
  if ( is_debug )
    draw( patch_targets{i}.Bounds, window );
  end
end

end

function draw_cursor(program)

pct.util.draw_gaze_cursor( program );

end

function check_targets(state, program)

patch_targets = program.Value.patch_targets;
stimuli = program.Value.stimuli;

for i = 1:numel(patch_targets)
  stim_name = pct.util.nth_patch_stimulus_name( i );
  stimulus = stimuli.(stim_name);
    
  if ( patch_targets{i}.IsDurationMet )
    stimulus.FaceColor = [0, 0, 0];
    
    if ( ~state.UserData.patch_elapsed_state(i) )
      state.UserData.patch_elapsed_state(i) = true;
      state.UserData.num_patches_remaining = state.UserData.num_patches_remaining - 1;
    end
  end
end

end

function position_stimuli(state, program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;

for i = 1:num_patches
  stim_name = pct.util.nth_patch_stimulus_name( i );
  new_pos = rand( 1, 2 );
  stimulus = stimuli.(stim_name);
  stimulus.Position.Value = new_pos;
end

end

function reset_targets(program)

num_patches = count_patches( program );
stimuli = program.Value.stimuli;
default_color = default_patch_color( program );

for i = 1:num_patches
  stim_name = pct.util.nth_patch_stimulus_name( i );
  stimulus = stimuli.(stim_name);
  stimulus.FaceColor = default_color;
end

patch_targets = program.Value.patch_targets;

for i = 1:numel(patch_targets)
  reset( patch_targets{i} );
end

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

end

function color = default_patch_color(program)

color = program.Value.stimuli_setup.patch.color;

end
