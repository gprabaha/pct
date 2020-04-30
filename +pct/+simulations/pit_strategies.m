function pit_strategies(m1_strategy, m2_strategy, m1_error_rate, ...
  m2_error_rate, coop_reward, max_moves, n_reps, num_patches, ...
  save_data_flag, save_fig_flag)

% Validation of input parameters
if nargin<3
  error('Too few arguments. Need the strategies of m1 and m2');
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

if isempty(save_data_flag)
  save_data_flag = 1;
end

if isempty(save_fig_flag)
  save_fig_flag = 0;
end

trial_sequence = pct.simuiations.make_trial_sequence( num_patches, n_reps );
patch_acquired_state = zeros( size( trial_sequence ) );
reward_queue = nan( [size( trial_sequence ) 2] );

m1_identity = 1;
m2_identity = 2;

for trial = 1:size(trial_sequence, 2)
  patches = trial_sequence(:, trial);
  acquired_patches = patch_acquired_state(:, trial);
  current_reward = zeros( size(trial_sequence, 1), 2 );
  
  for move = 1:max_moves
    m1_patch_choice = pct.simulations.apply_strategy(m1_identity, m1_strategy, ...
      m1_error_rate, patches, acquired_patches);
    m2_patch_choice = pct.simulations.apply_strategy(m2_identity, m2_strategy, ...
      m2_error_rate, patches, acquired_patches);
    [acquired_patches, reward] = pct.simulations.distribute_rewards(patches, ...
      current_reward, m1_patch_choice, m2_patch_choice);
    current_reward = reward;
    
    if all(acquired_patches == 1)
      break
    end
  end
  reward_queue(:, trial, 1) = current_reward(:, 1);
  reward_queue(:, trial, 2) = current_reward(:, 2);
  patch_acquired_state(:, trial) = acquired_patches;
end