function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

update_training_stages( program );
update_data_scaffold( program );
process_data( program );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end

function update_data_scaffold(program)

if ( isempty(program.Value.data.Value) )
    program.Value.data.Value = make_trial_data_scaffold( program );
else
    program.Value.data.Value(end+1) = make_trial_data_scaffold( program );
end

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

data_scaffold.training_stage_name = program.Value.training_stage_name;

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
  online_data_rep.Value(trials_so_far).training_stage_name = data(trials_so_far).training_stage_name;

  display_data( online_data_rep, program );
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

function display_data(online_data_rep, program)

clc;

if( length( online_data_rep.Value ) < 11 )
  data_cell = cell( length( online_data_rep.Value ), 5 );
  for trial = 1:length( online_data_rep.Value )
    data_cell(trial,:) = {trial online_data_rep.Value(trial).did_correctly ...
      online_data_rep.Value(trial).last_state_reached ...
      online_data_rep.Value(trial).response_times ...
      online_data_rep.Value(trial).training_stage_name};
  end
  data_table = cell2table(data_cell,...
    'VariableNames',{'Trial_no' 'Correct' 'Last_state' 'Resp_time' 'Training_stage'});
else
  data_cell = cell( 10, 5 );
  for trial = (numel( online_data_rep.Value ) - 9):numel( online_data_rep.Value )
    data_cell(trial - ( numel( online_data_rep.Value ) - 10 ),:) = ...
      {trial online_data_rep.Value(trial).did_correctly ...
      online_data_rep.Value(trial).last_state_reached ...
      online_data_rep.Value(trial).response_times ...
      online_data_rep.Value(trial).training_stage_name};
  end
  data_table = cell2table(data_cell,...
    'VariableNames',{'Trial_no' 'Correct' 'Last_state' 'Resp_time' 'Training_stage'});
end

overall_accuracy = mean([online_data_rep.Value(1:end).did_correctly])*100;

fprintf( 'The overall accuracy is: %0.2f percent\n\n', overall_accuracy );
disp(data_table)

display_juice_received( online_data_rep, program );
if ~strcmp( online_data_rep.Value(end).training_stage_name, ...
    program.Value.training_stage_name )
  display_training_stage( program );
end

display_training_stage_parameters( program );

end

function display_training_stage(program)

fprintf( '\n!!!Transitioning to training stage: %s!!!\n\n ', program.Value.training_stage_name );

end

function display_training_stage_parameters(program)

fix_time = program.Value.targets.fix_square.Duration;
fix_hold_time = program.Value.targets.fix_hold_square.Duration;
patch_name = pct.util.nth_patch_stimulus_name( 1 );
patch_time = program.Value.targets.(patch_name).Duration;

fprintf( '\n## Parameters of the current training stage ##\n\n' );
fprintf( 'Fixation time: %0.2f seconds\n', fix_time );
fprintf( 'Fixation and hold time: %0.2f seconds\n', fix_hold_time );
fprintf( 'Patch collection time: %0.2f seconds', patch_time );

end

function display_juice_received(online_data_rep, program)

juice_reward_time = program.Value.rewards.training;
total_reward = sum([online_data_rep.Value(1:end).did_correctly])*juice_reward_time;
fprintf( '\nTotal reward received so far = %0.2f seconds worth\n ', total_reward );

end

function update_training_stages(program)

manager = program.Value.training_stage_manager;
apply( manager, program );

end