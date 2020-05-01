clear;
clf;
clc;

num_patches = 2;

m1_error_rate = 0.1; % Error rate per saccade for m1
m2_error_rate = 0.1; % Error rate per saccade for m2

m1_win_prob = 0.5; % Probability of m1 willing in competition
coop_reward = 0.5; % Fraction of reward each monkey gets for acquiring a cooperation patch
choice_prob_list = [0.6 0.25 0.15]; % Hierarchical choice probability; preferred -> unpreferred

n_reps = 10; % Number of repetitions for each trial type
n_sessions = 20; % Number of experimental sessions
max_moves = 2; % Maximum number of moves that can be made per trial (and thus max number of patches collected)

save_data_flag = 1;
save_fig_flag = 0;

strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
  'interactive-cooperate', 'benevolent', 'random', 'wsls'};

for m1_strategy = strategy_list
  for m2_strategy = strategy_list
    for session = 1:n_sessions
      pct.simulations.pit_strategies( m1_strategy, m2_strategy,...
        m1_error_rate, m2_error_rate, choice_prob_list, m1_win_prob, ...
        coop_reward, max_moves, n_reps, num_patches, save_data_flag, save_fig_flag );
    end
  end
end