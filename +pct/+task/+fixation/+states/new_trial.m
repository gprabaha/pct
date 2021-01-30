function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

states = program.Value.states;
task = program.Value.task;
pause_flag = program.Value.pause_flag;

should_escape = establish_patch_info( program );
configure_patch_stimuli( program );

if ( should_escape )
  escape( task );
  return
end

if ( should_go_to_pause_state(program) &&  ~pause_flag )
  next( state, states('pause') );
else
  update_training_stages( program );
  update_data_scaffold( program, program.Value.current_patches );
  process_data( program );
  program.Value.pause_flag = false;
  
  next( state, states('fixation') );
end

end

function loop(state, program)

end

function exit(state, program)

end

function update_data_scaffold(program, patch_info)

scaffold = make_trial_data_scaffold( program, patch_info );

if ( isempty(program.Value.data.Value) )
  program.Value.data.Value = scaffold;
else
  program.Value.data.Value(end+1) = scaffold;
end

end

function data_scaffold = make_trial_data_scaffold(program, patch_info)

% Initial assignments %

data_scaffold                         = struct();
data_scaffold.metadata                = program.Value.metadata;
data_scaffold.trial_index             = program.Value.current_trial_index;
data_scaffold.trial_sequence          = program.Value.current_patch_sequence_index; % Which part of trial?
data_scaffold.last_state              = nan;
data_scaffold.last_patch_type         = nan;
data_scaffold.last_agent              = nan;
data_scaffold.m2_saccade_time         = nan;
data_scaffold.patch_info              = patch_info;

% For states in the first part of the trial %

% fixation
data_scaffold.fixation.entry_time = nan;
data_scaffold.fixation.exit_time = nan;
data_scaffold.fixation.did_fixate = nan;

% fix_hold_patch
data_scaffold.fix_hold_patch.entry_time = nan;
data_scaffold.fix_hold_patch.exit_time = nan;
data_scaffold.fix_hold_patch.did_fixate = nan;

% just_patches
data_scaffold.just_patches.entry_time = nan;
% The first dimension is agent index and the second one is patch index
data_scaffold.just_patches.patch_entry_times = cell( 2, count_patches( program ) );
data_scaffold.just_patches.patch_exit_times = cell( 2, count_patches( program ) );
data_scaffold.just_patches.patch_acquired_times = nan( 2, count_patches( program ) );
data_scaffold.just_patches.exit_time = nan;
data_scaffold.just_patches.did_fixate = nan;
data_scaffold.just_patches.acquired_patches = cell( 1, count_patches(program) );

% Deviation states %

% error_penalty
data_scaffold.error_penalty.entry_time = nan;
data_scaffold.error_penalty.exit_time = nan;
data_scaffold.error_penalty.did_fixate = nan;

% pause
data_scaffold.pause.entry_time = nan;
data_scaffold.pause.exit_time = nan;

% reward
data_scaffold.juice_reward.entry_time = nan;
data_scaffold.juice_reward.exit_time = nan;

% iti
data_scaffold.iti.entry_time = nan;
data_scaffold.iti.exit_time = nan;

data_scaffold.training_stage_reward = program.Value.rewards.training;

if ( isfield(program.Value, 'current_patch_identitites') )
  data_scaffold.patch_identities = program.Value.current_patch_identities;
else
  data_scaffold.patch_identities = {};
end

end

function num_patches = count_patches(program)

num_patches = numel( program.Value.current_patches );

end

function process_data(program)

%
data                = program.Value.data.Value;
interface           = program.Value.interface;
online_data_rep     = program.Value.online_data_rep;



if( length(data) > 1 )
  trials_so_far = length(data) - 1;
  
  online_data_rep.Value(trials_so_far).m1_agent               = data(trials_so_far).metadata.m1_agent;
  online_data_rep.Value(trials_so_far).m2_agent               = data(trials_so_far).metadata.m2_agent;
  online_data_rep.Value(trials_so_far).did_initiate           = check_if_initiated( data, trials_so_far );
  % Follow Nick's suggestion with finding accuracy through PatchesAcquied
  online_data_rep.Value(trials_so_far).did_correctly          = check_if_correct( data, trials_so_far );
  online_data_rep.Value(trials_so_far).frac_initiated         = check_frac_initiated( data, trials_so_far );
  online_data_rep.Value(trials_so_far).patch_legend           = check_patch_legend( program );
  online_data_rep.Value(trials_so_far).trial_index            = data(trials_so_far).trial_index;
  online_data_rep.Value(trials_so_far).trial_sequence         = data(trials_so_far).trial_sequence;
  online_data_rep.Value(trials_so_far).last_state_reached     = check_last_state(data, trials_so_far);
  online_data_rep.Value(trials_so_far).patches_presented      = check_patches_presented( data, trials_so_far );
  online_data_rep.Value(trials_so_far).m1_choice              = check_m1_acquired_patch( data, trials_so_far );
  online_data_rep.Value(trials_so_far).m2_choice              = check_m2_acquired_patch( data, trials_so_far );
  
  if ( interface.display_task_progress )
    display_data( online_data_rep, program );
  end
end

end

function tf = check_if_initiated(data, trials_so_far)

tf = ~isnan( data(trials_so_far).fix_hold_patch.entry_time );

end

function tf = check_if_correct(data, trials_so_far)

tf = ~isnan( data(trials_so_far).error_penalty.entry_time );

end

function frac_initiated = check_frac_initiated(data, trials_so_far)

% Initial assignment %

frac_initiated            = struct();
first_seq_did_initiate    = [];
second_seq_did_initiate   = [];

% Operations %

trial_sequences = [ data(1:trials_so_far).trial_sequence ];

first_seq_data = data( trial_sequences == 1 );
second_seq_data = data( trial_sequences == 2 );

if ~isempty( first_seq_data )
  first_init_data = [ first_seq_data(1:end).fix_hold_patch ];
  first_seq_did_initiate = ~isnan( [ first_init_data(1:end).entry_time ] );
  frac_init_first_seq_overall = mean( first_seq_did_initiate );
else
  frac_init_first_seq_overall = 0;
end
if ~isempty( second_seq_data )
  second_init_data = [ second_seq_data(1:end).fix_hold_patch ];
  second_seq_did_initiate = ~isnan( [ second_init_data(1:end).entry_time ] );
  frac_init_second_seq_overall = mean( second_seq_did_initiate );
else
  frac_init_second_seq_overall = 0;
end

if numel(first_seq_did_initiate) < 50
  frac_init_first_seq_last_50 = frac_init_first_seq_overall;
else
  frac_init_first_seq_last_50 = mean( first_seq_did_initiate(end-50:end) );
end
if numel(second_seq_did_initiate) < 50
  frac_init_second_seq_last_50 = frac_init_second_seq_overall;
else
  frac_init_second_seq_last_50 = mean( second_seq_did_initiate(end-50:end) );
end

frac_initiated.first_seq_overall = frac_init_first_seq_overall;
frac_initiated.second_seq_overall = frac_init_second_seq_overall;
frac_initiated.first_seq_last_50 = frac_init_first_seq_last_50;
frac_initiated.second_seq_last_50 = frac_init_second_seq_last_50;

end

function patch_legend = check_patch_legend(program)

% Initial assignment %

patch_info        = pct.util.PatchInfo.empty();
patch_generator   = pct.util.FourPatchTrialSet;
appearance_func   = program.Value.stimuli_setup.patch.patch_appearance_func;
red               = [255, 0, 0];
purple            = [102, 0, 255];
green             = [0, 255, 0];
cyan              = [255, 255, 0];
yellow            = [0, 255, 255];
patch_legend      = {};

% Operations %

patch_types = patch_generator.fetch_patch_types();
for index = 1:numel( patch_types )
  current_patch_info                = pct.util.PatchInfo();
  current_patch_info.AcquirableBy   = patch_types{index}.acquirable_by;
  current_patch_info.Agent          = patch_types{index}.agent;
  current_patch_info.Strategy       = patch_types{index}.strategy;
  current_patch_info.Position       = [];
  current_patch_info.Target         = [];
  current_patch_info.Index          = index;
  current_patch_info.ID             = index;
  current_patch_info.TrialTypeID    = index;
  current_patch_info.SequenceID     = index;
  current_patch_info                = appearance_func( current_patch_info );
  patch_info(end+1)                 = current_patch_info;
end

for patch_index = 1:numel( patch_info )
  color = patch_info(patch_index).Color;
  % Self-M1 patch for Hitch
  if all(color == red)
    color_str = 'Red => M1 (hitch)';
    patch_legend = update_patch_legend( patch_legend, color_str );
  % Self-M2 patch for Computer
  elseif all(color == purple)
    color_str = 'Purple => M2 (computer_naive_random)';
    patch_legend = update_patch_legend( patch_legend, color_str );
  % Compete patch
  elseif all(color == yellow)
    color_str = 'Yellow => Compete (either)';
    patch_legend = update_patch_legend( patch_legend, color_str );
  % Cooperate patch
  elseif all(color == cyan)
    color_str = 'Cyan => Cooperate (both)';
    patch_legend = update_patch_legend( patch_legend, color_str );
  else
    color_str = 'Unidentified patch color';
    patch_legend = update_patch_legend( patch_legend, color_str );
  end
end
end

function patch_legend = update_patch_legend(patch_legend, color_str)
if isempty(patch_legend)
  patch_legend{1} = color_str;
else
  if ~any( strcmp( patch_legend, color_str ) )
    patch_legend{end+1} = color_str;
  end
end
end


function last_state_reached = check_last_state(data, trials_so_far)

last_state_reached = data(trials_so_far).last_state;

end

function patch_str = check_patches_presented(data, trials_so_far)

patch_info          = data(trials_so_far).patch_info;
patches_presented   = {};
patch_str           = '';

if( check_if_initiated(data, trials_so_far) )
  for index = 1:numel( patch_info )
    patches_presented{index} = patch_info(index).Strategy;
    if strcmp(patches_presented{index}, 'self')
      patches_presented{index} = [patches_presented{index}, '-', ...
        patch_info(index).AcquirableBy{1}];
    end
  end
  for index = 1:numel( patches_presented )
    if ( isempty( patch_str ) )
      patch_str = patches_presented{index};
    else
      patch_str = [patch_str '|' patches_presented{index}];
    end
  end
end

end

function m1_acquired_patch = check_m1_acquired_patch(data, trials_so_far)

% Initial assignment %

acquired_patches    = data(trials_so_far).just_patches.acquired_patches;
m1_acquired_patch   = [];

% Operations %

if isempty( acquired_patches )
  m1_acquired_patch = 'none';
else
  for patch_index = 1:numel( acquired_patches )
    maybe_patch_info = acquired_patches{patch_index};
    if ( ~isempty(maybe_patch_info) && maybe_patch_info.AcquiredByIndex == pct.util.m1_agent_index() )
      m1_acquired_patch = maybe_patch_info.Strategy;
      break
    end
  end
  if isempty(  m1_acquired_patch )
    m1_acquired_patch = 'none';
  end
end

end

function m2_acquired_patch = check_m2_acquired_patch(data, trials_so_far)

% Initial assignment %

acquired_patches    = data(trials_so_far).just_patches.acquired_patches;
m2_acquired_patch   = [];

% Operations %

if isempty( acquired_patches )
  m2_acquired_patch = 'none';
else
  for patch_index = 1:numel( acquired_patches )
    maybe_patch_info = acquired_patches{patch_index};
    if ( ~isempty(maybe_patch_info) && maybe_patch_info.AcquiredByIndex == pct.util.m2_agent_index() )
      m2_acquired_patch = maybe_patch_info.Strategy;
      break
    end
  end
  if isempty(  m2_acquired_patch )
    m2_acquired_patch = 'none';
  end
end

end

function last_patch_type = check_last_patch_type(data, trials_so_far)

last_patch_type = data(trials_so_far).last_patch_type;

end

function last_patch_type_id = check_last_patch_type_id(data, trials_so_far)

patch_type = data(trials_so_far).last_patch_type;
if strcmp(patch_type, 'self')
  last_patch_type_id = 1;
elseif strcmp(patch_type, 'compete')
  last_patch_type_id = 3;
elseif strcmp(patch_type, 'cooperate')
  last_patch_type_id = 4;
else
  last_patch_type_id = 0;
end

end

function last_agent = check_last_agent(data, trials_so_far)

last_agent = data(trials_so_far).last_agent;

end

function last_agent_id = check_last_agent_id(data, trials_so_far)

last_agent = data(trials_so_far).last_agent;
if strcmp(last_agent, 'hitch')
  last_agent_id = 1;
elseif strcmp(last_agent, 'computer_naive_random')
  last_agent_id = 2;
else
  last_agent_id = 0;
end

end

function display_data(online_data_rep, program)

interface = program.Value.interface;
num_trials_to_display = interface.num_trials_to_display;

clc;

display_m1_agent( online_data_rep );
display_m2_agent( online_data_rep );
display_frac_initiated_trials( online_data_rep );
display_accuracy( online_data_rep );
display_patch_legend( online_data_rep );
display_last_n_trials( online_data_rep, num_trials_to_display );

end

function display_m1_agent(online_data_rep)

m1_agent = online_data_rep.Value(end).m1_agent;
fprintf( '\nM1 agent: %s\n', m1_agent);

end

function display_m2_agent(online_data_rep)

m2_agent = online_data_rep.Value(end).m2_agent;
fprintf( 'M2 agent: %s\n', m2_agent);

end

function display_accuracy( online_data_rep )

% foo

end

function display_frac_initiated_trials(online_data_rep)

% Initial assignment %

frac_initiated = online_data_rep.Value(end).frac_initiated;

% Operations %

fprintf( '\nFrac. of 1st seq trials initiated. Overall: %0.2f; Past 50 trials: %0.2f\n', ...
  frac_initiated.first_seq_overall, frac_initiated.first_seq_last_50 );
fprintf( '\nFrac. of 2nd seq trials initiated. Overall: %0.2f; Past 50 trials: %0.2f\n', ...
  frac_initiated.second_seq_overall, frac_initiated.second_seq_last_50 );

end

function display_patch_legend(online_data_rep)

patch_legend = online_data_rep.Value(end).patch_legend;
fprintf( '\n# Legend of patches displayed #\n' );
fprintf( '-------------------------------\n\n' );
for index = 1:numel( patch_legend )
  disp( patch_legend{index} );
end

end

function display_last_n_trials(online_data_rep, n)

trial_indices = [ online_data_rep.Value(1:end).trial_index ];
unique_trials = unique( trial_indices );

if ( numel( unique_trials ) < n+1 )
  data_cell = cell( length( online_data_rep.Value ), 6 );
  for trial = 1:numel( online_data_rep.Value )
    data_cell(trial,:) = { ...
      online_data_rep.Value(trial).trial_index, ...
      online_data_rep.Value(trial).trial_sequence, ...
      online_data_rep.Value(trial).last_state_reached, ...
      online_data_rep.Value(trial).patches_presented, ...
      online_data_rep.Value(trial).m1_choice, ...
      online_data_rep.Value(trial).m2_choice
      };
  end
  data_table = cell2table(data_cell,...
    'VariableNames',{'Trial' 'Seq' 'Last_st' 'Patches' 'M1_acq' 'M2_acq'});
else
  oldest_trial = unique_trials(end - n + 1);
  oldest_trial_index = find( trial_indices == oldest_trial , 1 );
  for trial = oldest_trial_index:numel( online_data_rep.Value )
    data_cell(trial-oldest_trial_index+1,:) = { ...
      online_data_rep.Value(trial).trial_index, ...
      online_data_rep.Value(trial).trial_sequence, ...
      online_data_rep.Value(trial).last_state_reached, ...
      online_data_rep.Value(trial).patches_presented, ...
      online_data_rep.Value(trial).m1_choice, ...
      online_data_rep.Value(trial).m2_choice
      };
  end
  data_table = cell2table(data_cell,...
    'VariableNames',{'Trial' 'Seq' 'Last_st' 'Patches' 'M1_acq' 'M2_acq'});
end

fprintf( '\n# Performance over the last %d trials #\n', n );
fprintf( '---------------------------------------\n\n' );

disp(data_table);

end

function update_training_stages(program)

manager = program.Value.training_stage_manager;
apply( manager, program );

end

function tf = should_go_to_pause_state(program)

tf = program.Value.structure.pause_state_criterion( program );

end

function should_abort = establish_patch_info(program)

all_targets = program.Value.patch_targets;

[patch_info, trial_index, patch_sequence_index, should_abort] = ...
  generate( program.Value.patch_generator, all_targets, program );

program.Value.current_patches = patch_info;
program.Value.current_patch_sequence_index = patch_sequence_index;
program.Value.current_trial_index = trial_index;

end

function configure_patch_stimuli(program)

num_patches = count_patches( program );

stimuli = program.Value.stimuli;
current_patches = program.Value.current_patches;
current_stimuli = cell( 1, num_patches );

for i = 1:num_patches
  patch_info = current_patches(i);
  
  % @Note: This is a bit tricky. The patch index may be different from
  % the value `i`, in the case that it is a hold-over patch from a previous
  % trial.
  stim_name = pct.util.nth_patch_stimulus_name( patch_info.Index );
  stimulus = stimuli.(stim_name);
  
  patch_color = patch_info.Color;
  patch_pos = patch_info.Position;
  
  stimulus.FaceColor = patch_color;
  stimulus.Position.Value = patch_pos;
  
  current_stimuli{i} = stimulus;
end

program.Value.current_patch_stimuli = current_stimuli;

end

function time = maybe_get_m2_saccade_time(program)

if ( isfield(program.Value, 'generator_m2') )
  time = program.Value.generator_m2.get_current_saccade_time();
else
  time = 0;
end

end