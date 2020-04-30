clear;
clf;
clc;

num_patches = 2;

m1_error_rate = 0.1; % Error rate per saccade for m1
m2_error_rate = 0.1; % Error rate per saccade for m2

n_reps = 10; % Number of repetitions for each trial type
n_sessions = 20; % Number of experimental sessions
coop_reward = 0.5; % Fraction of reward each monkey gets for acquiring a cooperation patch
max_moves = 2; % Maximum number of moves that can be made per trial (and thus max number of patches collected)

save_data_flag = 1;
save_fig_flag = 0;

strategy_list = {'selfish', 'competitive', 'interactive', 'benevolent', ...
  'wsls', 'random'};

for m1_strategy = strategy_list
  for m2_strategy = strategy_list
    for session = 1:n_sessions
      pct.simulations.pit_strategies( m1_strategy, m2_strategy,...
        m1_error_rate, m2_error_rate, coop_reward, max_moves, n_reps, ...
        num_patches, save_data_flag, save_fig_flag );
    end
  end
end