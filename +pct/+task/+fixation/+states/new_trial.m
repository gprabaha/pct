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

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('fixation') );

end

function data_scaffold = make_trial_data_scaffold(program)

data_scaffold = struct();

data_scaffold.fixation.entry_time = nan;
data_scaffold.fixation.exit_time = nan;
data_scaffold.fixation.did_fixate = nan;

data_scaffold.fix_hold_patch.entry_time = nan;
data_scaffold.fix_hold_patch.exit_time = nan;
data_scaffold.fix_hold_patch.did_fixate = nan;

data_scaffold.just_patches.entry_time = nan;
data_scaffold.just_patches.patch_entry_times = cell( 1, count_patches( program ) );
data_scaffold.just_patches.patch_exit_times = cell( 1, count_patches( program ) );
data_scaffold.just_patches.exit_time = nan;
data_scaffold.just_patches.did_fixate = nan;

data_scaffold.error_penalty.entry_time = nan;
data_scaffold.error_penalty.exit_time = nan;
data_scaffold.error_penalty.did_fixate = nan;

end

function num_patches = count_patches(program)

num_patches = program.Value.structure.num_patches;

end