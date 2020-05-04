function sim_results = pit_strategies(m1_strategy, m2_strategy, m1_error_rate, ...
  m2_error_rate, choice_prob_list, m1_win_prob, coop_reward, max_moves, ...
  n_reps, num_patches)

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

trial_sequence = pct.simulations.make_trial_sequence( num_patches, n_reps );
patch_acquired_state = zeros( size( trial_sequence ) );
reward_queue = nan( [size( trial_sequence ) 2] );
choice_sequence = cell(2, size(trial_sequence, 2));

m1_identity = 1;
m2_identity = 2;

for trial = 1:size(trial_sequence, 2)
  patches = trial_sequence(:, trial);
  acquired_patches = patch_acquired_state(:, trial);
  current_reward = zeros( size(trial_sequence, 1), 2 );
  choice_sequence{1,trial} = [];
  choice_sequence{2,trial} = [];
  
  for move = 1:max_moves
    m1_patch_choice = pct.simulations.apply_strategy(m1_identity, m1_strategy, ...
      choice_prob_list, m1_error_rate, patches, acquired_patches);
    m2_patch_choice = pct.simulations.apply_strategy(m2_identity, m2_strategy, ...
      choice_prob_list, m2_error_rate, patches, acquired_patches);
    [patches_acquired, reward] = pct.simulations.distribute_rewards(patches, ...
      current_reward, acquired_patches, m1_win_prob, coop_reward, ...
      m1_patch_choice, m2_patch_choice);
    
    choice_sequence{1,trial} = [choice_sequence{1,trial} m1_patch_choice];
    choice_sequence{2,trial} = [choice_sequence{2,trial} m2_patch_choice];
    
    acquired_patches = patches_acquired;
    current_reward = reward;
    
    if all(acquired_patches == 1)
      break
    end
  end
  reward_queue(:, trial, 1) = current_reward(:, 1);
  reward_queue(:, trial, 2) = current_reward(:, 2);
  patch_acquired_state(:, trial) = acquired_patches;
end

sim_results = struct();
sim_results.num_patches = num_patches;
sim_results.m1_strategy = m1_strategy;
sim_results.m2_strategy = m2_strategy;
sim_results.trial_sequence = trial_sequence;
sim_results.reward_queue = reward_queue;
sim_results.choice_sequence = choice_sequence;
sim_results.patch_acquired_state = patch_acquired_state;
sim_results.n_reps = n_reps;
sim_results.m1_error_rate = m1_error_rate;
sim_results.m2_error_rate = m2_error_rate;
sim_results.m1_win_prob = m1_win_prob;
sim_results.coop_reward = coop_reward;
sim_results.max_moves = max_moves;

legend = cell(13,1);
n=0;
n=n+1; legend{n} = 'num_patches           = number of patches per trial';
n=n+1; legend{n} = 'm1_strategy           = strategy used by m1';
n=n+1; legend{n} = 'm2_strategy           = strategy used by m2';
n=n+1; legend{n} = 'trial_sequence        = specific trial order in the session';
n=n+1; legend{n} = 'reward_queue          = reward received for each patch on each trial by both monkeys';
n=n+1; legend{n} = 'choice_sequence       = account of patch choices in each trial for each monkey';
n=n+1; legend{n} = 'patch_acquired_state  = whether each patch in each trial was acquired';
n=n+1; legend{n} = 'n_reps                = number of repeats of each trial';
n=n+1; legend{n} = 'm1_error_rate         = error probability per move for m1';
n=n+1; legend{n} = 'm2_error_rate         = error probability per move for m2';
n=n+1; legend{n} = 'm1_win_prob           = probability of m1 winning comp. patch';
n=n+1; legend{n} = 'coop_reward           = amount of reward each monkey gets by acquiring a coop. patch';
n=n+1; legend{n} = 'max_moves             = maximum number of moves allowed, per monkey, per trial';

sim_results.legend = legend;