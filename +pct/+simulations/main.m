clear;
clf;
clc;

num_patches = 2;

n_reps = 10;
n_sessions = 20;
coop_reward = 0.5;
save_data_flag = 1;
save_fig_flag = 0;

strategy_list = {'selfish', 'competitive', 'interactive', 'benevolent', ...
  'wsls', 'random'};

for m1_strategy = strategy_list
  for m2_strategy = strategy_list
    for session = 1:n_sessions
      pct.simulations.pit_strategies( m1_strategy, m2_strategy,...
        coop_reward, n_reps, num_patches, save_data_flag, save_fig_flag );
    end
  end
end