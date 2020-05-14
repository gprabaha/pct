function sim_results = pit_strategies(m1_strategy, m2_strategy, m1_error_rate, ...
  m2_error_rate, choice_prob_list, m1_win_prob, coop_reward, max_moves, ...
  n_reps, num_patches, decay_rate, session)

% Validation of input parameters
if nargin<3
  error('Too few arguments. Need at least the strategies of m1 and m2');
end

if isempty(m1_error_rate)
  m1_error_rate = 0.1;
end

if isempty(m2_error_rate)
  m2_error_rate = 0.1;
end

if isempty(m1_win_prob)
  m1_win_prob = 0.5;
end

if isempty(coop_reward)
  coop_reward = 0.5;
end

if isempty(max_moves)
  max_moves = 2;
end

if isempty(n_reps)
  n_reps = 10;
end

if isempty(num_patches)
  num_patches = 2;
end

if isempty(decay_rate)
  decay_rate = nthroot(0.5, 3);
end

trial_sequence = pct.simulations.make_trial_sequence( num_patches, n_reps );
patch_acquired_state = zeros( size( trial_sequence ) );

m1_identity = 1;
m2_identity = 2;

% Struct legend for each trial
legend = cell(13,1);
n=0;
n=n+1; legend{n} = 'num_patches                         = number of patches per trial';
n=n+1; legend{n} = 'm1_strategy                         = strategy used by m1';
n=n+1; legend{n} = 'm2_strategy                         = strategy used by m2';
n=n+1; legend{n} = 'session                             = particular experimental session';
n=n+1; legend{n} = 'trial_patches                       = specific patches in trial';
n=n+1; legend{n} = 'reward                              = reward received for each patch by both monkeys';
n=n+1; legend{n} = 'choice_sequence_m1                  = patch choice sequence for m1';
n=n+1; legend{n} = 'choice_sequence_m2                  = patch choice sequence for m2';
n=n+1; legend{n} = 'patch_acquired_state                = whether each patch was acquired';
n=n+1; legend{n} = 'patch_value_after_trial_unchosen    = current patch value where unchosen and unrewarded is treated as same';
n=n+1; legend{n} = 'patch_value_after_trial_unrewarded  = current patch value where unchosen and unrewarded is treated differently';
n=n+1; legend{n} = 'n_reps                              = number of repeats of each trial';
n=n+1; legend{n} = 'm1_error_rate                       = error probability per move for m1';
n=n+1; legend{n} = 'm2_error_rate                       = error probability per move for m2';
n=n+1; legend{n} = 'm1_win_prob                         = probability of m1 winning comp. patch';
n=n+1; legend{n} = 'coop_reward                         = amount of reward each monkey gets by acquiring a coop. patch';
n=n+1; legend{n} = 'max_moves                           = maximum number of moves allowed, per monkey, per trial';

current_value_unchosen_m1 = [1 0 1 1];
current_value_unchosen_m2 =  [0 1 1 1];
current_value_unrewarded_m1 = [1 0 1 1];
current_value_unrewarded_m2 = [0 1 1 1];

for trial = 1:size(trial_sequence, 2)
  
  sim_results(trial) = make_trial_data_structure();
  
  patches = trial_sequence(:, trial);
  acquired_patches = patch_acquired_state(:, trial);
  current_reward = zeros( size(trial_sequence, 1), 2 );
  all_choices_m1 = zeros( size(trial_sequence, 1), 1 );
  all_choices_m2 = zeros( size(trial_sequence, 1), 1 );
  choice_sequence_m1 = [];
  choice_sequence_m2 = [];
  
  for move = 1:max_moves
    m1_patch_choice = pct.simulations.apply_strategy(m1_identity, m1_strategy, ...
      choice_prob_list, current_value_unchosen_m1, ...
      current_value_unrewarded_m1, m1_error_rate, patches, acquired_patches);
    m2_patch_choice = pct.simulations.apply_strategy(m2_identity, m2_strategy, ...
      choice_prob_list, current_value_unchosen_m2, ...
      current_value_unrewarded_m2, m2_error_rate, patches, acquired_patches);
    [patches_acquired, reward] = pct.simulations.distribute_rewards(patches, ...
      current_reward, acquired_patches, m1_win_prob, coop_reward, ...
      m1_patch_choice, m2_patch_choice);
    
    all_choices_m1 = all_choices_m1 | m1_patch_choice;
    all_choices_m2 = all_choices_m2 | m2_patch_choice;
    choice_sequence_m1 = [choice_sequence_m1 m1_patch_choice];
    choice_sequence_m2 = [choice_sequence_m2 m2_patch_choice];
    
    
    acquired_patches = patches_acquired;
    current_reward = reward;
    
    if all(acquired_patches == 1)
      break
    end
  end
  
  [current_value_unchosen_m1, current_value_unchosen_m2] = ...
    update_value_unchosen(current_value_unchosen_m1, ...
    current_value_unchosen_m2, all_choices_m1, all_choices_m2, ...
    reward, patches, decay_rate);
  
  [current_value_unrewarded_m1, current_value_unrewarded_m2] = ...
  update_value_unrewarded(current_value_unrewarded_m1, ...
  current_value_unrewarded_m2, all_choices_m1, all_choices_m2, ...
  reward, patches, decay_rate);
  
  patch_acquired_state(:, trial) = acquired_patches;
  
  sim_results(trial).num_patches = num_patches;
  sim_results(trial).m1_strategy = m1_strategy;
  sim_results(trial).m2_strategy = m2_strategy;
  sim_results(trial).session = session;
  sim_results(trial).trial_patches = patches;
  sim_results(trial).reward = current_reward;
  sim_results(trial).choice_sequence_m1 = choice_sequence_m1;
  sim_results(trial).choice_sequence_m2 = choice_sequence_m2;
  sim_results(trial).patch_acquired_state = patch_acquired_state(:, trial);
  sim_results(trial).patch_value_after_trial_unchosen = [current_value_unchosen_m1; current_value_unchosen_m2];
  sim_results(trial).patch_value_after_trial_unrewarded = [current_value_unrewarded_m1; current_value_unrewarded_m2];
  sim_results(trial).n_reps = n_reps;
  sim_results(trial).m1_error_rate = m1_error_rate;
  sim_results(trial).m2_error_rate = m2_error_rate;
  sim_results(trial).m1_win_prob = m1_win_prob;
  sim_results(trial).coop_reward = coop_reward;
  sim_results(trial).max_moves = max_moves;
  sim_results(trial).legend = legend;
end

end

function data_structure = make_trial_data_structure()

data_structure = struct();

data_structure.num_patches = nan;
data_structure.m1_strategy = nan;
data_structure.m2_strategy = nan;
data_structure.session = nan;
data_structure.trial_patches = nan;
data_structure.reward = nan;
data_structure.choice_sequence_m1 = nan;
data_structure.choice_sequence_m2 = nan;
data_structure.patch_acquired_state = nan;
data_structure.patch_value_after_trial_unchosen = nan;
data_structure.patch_value_after_trial_unrewarded = nan;
data_structure.n_reps = nan;
data_structure.m1_error_rate = nan;
data_structure.m2_error_rate = nan;
data_structure.m1_win_prob = nan;
data_structure.coop_reward = nan;
data_structure.max_moves = nan;
data_structure.legend = nan;
  
end


function [updated_value_unchosen_m1, updated_value_unchosen_m2] = ...
  update_value_unchosen(current_value_unchosen_m1, ...
  current_value_unchosen_m2, all_choices_m1, all_choices_m2, ...
  reward, patches, decay_rate)

rewarded_patches_m1 = patches( reward(:,1)>0 );
rewarded_patches_m2 = patches( reward(:,2)>0 );

for patch_ind = 1:numel( rewarded_patches_m1 )
  patch = rewarded_patches_m1(patch_ind);
  current_value_unchosen_m1(patch) = current_value_unchosen_m1(patch)*(1/decay_rate);
end

for patch_ind = 1:numel( rewarded_patches_m2 )
  patch = rewarded_patches_m2(patch_ind);
  current_value_unchosen_m2(patch) = current_value_unchosen_m2(patch)*(1/decay_rate);
end

current_value_unchosen_m1 = current_value_unchosen_m1*decay_rate;
current_value_unchosen_m1 = current_value_unchosen_m1/max( current_value_unchosen_m1 );
current_value_unchosen_m2 = current_value_unchosen_m2*decay_rate;
current_value_unchosen_m2 = current_value_unchosen_m2/max( current_value_unchosen_m2 );

updated_value_unchosen_m1 = current_value_unchosen_m1;
updated_value_unchosen_m2 = current_value_unchosen_m2;

end

function [updated_value_unrewarded_m1, updated_value_unrewarded_m2] = ...
  update_value_unrewarded(current_value_unrewarded_m1, ...
  current_value_unrewarded_m2, all_choices_m1, all_choices_m2, ...
  reward, patches, decay_rate)

for patch_ind = 1:numel( all_choices_m1 )
  if all_choices_m1(patch_ind) == 1
    patch = patches(patch_ind);
    if reward(patch_ind, 1) == 1
      current_value_unrewarded_m1(patch) = current_value_unrewarded_m1(patch)*(1/decay_rate);
    else
      current_value_unrewarded_m1(patch) = current_value_unrewarded_m1(patch)*decay_rate;
    end
  end
end

for patch_ind = 1:numel( all_choices_m2 )
  if all_choices_m2(patch_ind) == 1
    patch = patches(patch_ind);
    if reward(patch_ind, 1) == 1
      current_value_unrewarded_m2(patch) = current_value_unrewarded_m2(patch)*(1/decay_rate);
    else
      current_value_unrewarded_m2(patch) = current_value_unrewarded_m2(patch)*decay_rate;
    end
  end
end

current_value_unrewarded_m1 = current_value_unrewarded_m1*decay_rate;
current_value_unrewarded_m1 = current_value_unrewarded_m1/max( current_value_unrewarded_m1 );
current_value_unrewarded_m2 = current_value_unrewarded_m2*decay_rate;
current_value_unrewarded_m2 = current_value_unrewarded_m2/max( current_value_unrewarded_m2 );

updated_value_unrewarded_m1 = current_value_unrewarded_m1;
updated_value_unrewarded_m2 = current_value_unrewarded_m2;

end