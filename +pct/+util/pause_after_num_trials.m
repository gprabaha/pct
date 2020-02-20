function tf = pause_after_num_trials(program, num_trials)

elapsed_trials = numel( program.Value.data.Value );
tf = mod( elapsed_trials, num_trials ) == 0 && elapsed_trials > 0;

if tf
  %program.Value.data.Value(end+1) = make_trial_data_scaffold( program );
end

end

function data_scaffold = make_trial_data_scaffold(program)

data_scaffold = struct();

data_scaffold.last_state = nan;
data_scaffold.is_pause = true;

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

data_scaffold.pause.entry_time = nan;
data_scaffold.pause.exit_time = nan;

data_scaffold.training_stage_name = program.Value.training_stage_name;
data_scaffold.training_stage_reward = program.Value.rewards.training;

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

end