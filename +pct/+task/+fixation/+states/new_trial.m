function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

if ( isempty(program.Value.data.Value) )
    program.Value.data.Value = make_trial_data_scaffold( program );
else
    program.Value.data.Value(end+1) = make_trial_data_scaffold( program );
end

display_training_stage( program );
process_data( program );
update_training_stages( program );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end

function data_scaffold = make_trial_data_scaffold(program)

data_scaffold = struct();

data_scaffold.last_state = nan;

data_scaffold.fixation.entry_time = nan;
data_scaffold.fixation.exit_time = nan;
data_scaffold.fixation.did_fixate = nan;

data_scaffold.fix_hold_patch.entry_time = nan;
data_scaffold.fix_hold_patch.exit_time = nan;
data_scaffold.fix_hold_patch.did_fixate = nan;

data_scaffold.just_patches.entry_time = nan;
data_scaffold.just_patches.patch_entry_times = cell( 1, count_patches( program ) );
data_scaffold.just_patches.patch_exit_times = cell( 1, count_patches( program ) );
data_scaffold.just_patches.patch_acquired_times = nan( 1, count_patches( program ) );
data_scaffold.just_patches.exit_time = nan;
data_scaffold.just_patches.did_fixate = nan;

data_scaffold.error_penalty.entry_time = nan;
data_scaffold.error_penalty.exit_time = nan;
data_scaffold.error_penalty.did_fixate = nan;

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

end

function process_data(program)

data = program.Value.data.Value;
online_data_rep = program.Value.online_data_rep;

if( length(data) > 1 )
  trials_so_far = length(data) - 1;

  online_data_rep.Value(trials_so_far).did_correctly = check_correct(data, trials_so_far);
  online_data_rep.Value(trials_so_far).last_state_reached = check_last_state(data, trials_so_far);
  online_data_rep.Value(trials_so_far).response_times = check_response_times(data, trials_so_far);

  display_data( online_data_rep );
end

end

function did_correctly = check_correct(data, trials_so_far)

if( isnan( data(trials_so_far).error_penalty.entry_time ) )
  did_correctly = true;
else
  did_correctly = false;
end

end

function last_state_reached = check_last_state(data, trials_so_far)

last_state_reached = data(trials_so_far).last_state;

end

function response_times = check_response_times(data, trials_so_far)

response_times = data(trials_so_far).just_patches.patch_acquired_times - ...
    data(trials_so_far).just_patches.entry_time;

end

function display_training_stage( program )

fprintf( '\nThe current training stage is: %s\n ', program.Value.training_stage_name );

end


function display_data( online_data_rep )

clc;
trial_no_str = sprintf( '%s ', 'Trial:');
trial_correct_str = sprintf( '%s ', 'Correct:' );
last_state_str = sprintf( '%s ', 'Last state:' );
response_time_str = sprintf( '%s ', 'Resp. time:' );

if( length( online_data_rep.Value ) < 11 )
  for trial = 1:length( online_data_rep.Value )
    trial_no_str = sprintf( '%s \t %d', trial_no_str, trial );
    trial_correct_str = sprintf( '%s \t %d', trial_correct_str, online_data_rep.Value(trial).did_correctly );
    last_state_str = sprintf( '%s \t %s', last_state_str, online_data_rep.Value(trial).last_state_reached );
    response_time_str = sprintf( '%s \t %0.2f', response_time_str, online_data_rep.Value(trial).response_times );
  end
else
  for trial = (length( online_data_rep.Value ) - 9):length( online_data_rep.Value )
    trial_no_str = sprintf( '%s \t %d', trial_no_str, trial );
    trial_correct_str = sprintf( '%s \t %d', trial_correct_str, online_data_rep.Value(trial).did_correctly );
    last_state_str = sprintf( '%s \t %s', last_state_str, online_data_rep.Value(trial).last_state_reached );
    response_time_str = sprintf( '%s \t %0.2f', response_time_str, online_data_rep.Value(trial).response_times );
  end
end

overall_accuracy = mean([online_data_rep.Value(1:end).did_correctly])*100;

fprintf( 'The overall accuracy is: %f percent\n', overall_accuracy );
fprintf( '\n%s \n', trial_no_str );
fprintf( '%s \n', trial_correct_str );
fprintf( '%s \n', last_state_str );
fprintf( '%s \n', response_time_str );

end

function update_training_stages(program)

manager = program.Value.training_stage_manager;
apply( manager, program );

end