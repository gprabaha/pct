clear;
clc;

num_patches = 2;

m1_error_rate = 0.1; % Error rate per saccade for m1
m2_error_rate = 0.1; % Error rate per saccade for m2

m1_win_prob = 0.5; % Probability of m1 willing in competition
coop_reward = 0.5; % Fraction of reward each monkey gets for acquiring a cooperation patch
choice_prob_list = [0.6 0.25 0.15]; % Hierarchical choice probability; preferred -> unpreferred

n_reps = 10; % Number of repetitions for each trial type
n_sessions = 20; % Number of experimental sessions
max_moves = 4; % Maximum number of moves that can be made per trial (and thus max number of patches collected)

save_data_flag = 1;
save_fig_flag = 0;

% strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
%   'interactive-cooperate', 'benevolent', 'random', 'wsls'};

strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
  'interactive-cooperate', 'benevolent', 'random'};

result_mat = [];

for m1_strategy_ind = 1:numel(strategy_list)
  for m2_strategy_ind = 1:numel(strategy_list)
    m1_strategy = strategy_list{m1_strategy_ind};
    m2_strategy = strategy_list{m2_strategy_ind};
    disp(['Starting to run strategy pair; M1 strategy: ', m1_strategy, '; M2 strategy: ', m2_strategy]);
    for session = 1:n_sessions
      result_mat = [result_mat pct.simulations.pit_strategies( ...
        m1_strategy, m2_strategy, m1_error_rate, m2_error_rate, ...
        choice_prob_list, m1_win_prob, coop_reward, max_moves, ...
        n_reps, num_patches, session)];
    end
    disp('Ran all sessions for this strategy pair');
  end
end

if save_data_flag
  legend = 'result_mat: dim-1 = m1-strategy; dim-2 = m2strategy; dim-3 = session';
  data_filename = ['./+data/', num2str(num_patches) '-patches-'...
    num2str(max_moves) '-moves-' num2str(100*coop_reward) '-coop-'...
    'run-' datestr(datetime, 'yyyy-mm-dd_HH-MM-SS')];
  save(data_filename, 'result_mat', 'legend', 'strategy_list');
end