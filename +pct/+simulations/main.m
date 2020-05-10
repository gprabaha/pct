clear;
clc;

% num_patches = 2;

% m1_error_rate = 0.1; % Error rate per saccade for m1
% m2_error_rate = 0.1; % Error rate per saccade for m2

% m1_win_prob = 0.5; % Probability of m1 willing in competition
% coop_reward = 0.5; % Fraction of reward each monkey gets for acquiring a cooperation patch
choice_prob_list = [0.6 0.25 0.15]; % Hierarchical choice probability; preferred -> unpreferred

n_reps = 10; % Number of repetitions for each trial type
n_sessions = 20; % Number of experimental sessions
% max_moves = 4; % Maximum number of moves that can be made per trial (and thus max number of patches collected)

save_data_flag = 1;
save_fig_flag = 0;

% strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
%   'interactive-cooperate', 'benevolent', 'random', 'wsls'};

strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
  'interactive-cooperate', 'benevolent', 'random'};

result_mat = [];

for num_patches = 2:4
  for coop_reward = [0.5 1]
    for max_moves = 2:4
      for m1_win_prob = 0.3:0.1:0.7
        for m1_error_rate = 0.05:0.05:0.4
          for m2_error_rate = 0.05:0.05:0.4
            for m1_strategy_ind = 1:numel(strategy_list)
              for m2_strategy_ind = 1:numel(strategy_list)
                m1_strategy = strategy_list{m1_strategy_ind};
                m2_strategy = strategy_list{m2_strategy_ind};
                fprintf(['Starting ... \n' ...
                  'num_patches: %d \n', ...
                  'coop_reward: %f \n', ...
                  'max_moves: %d \n', ...
                  'm1_error_rate: %f \n', ...
                  'm2_error_rate: %f \n', ...
                  'M1 strategy: %s \n', ...
                  'M2 strategy: %s \n \n', ...
                  ], num_patches, coop_reward, max_moves, m1_error_rate,...
                  m2_error_rate, m1_strategy, m2_strategy);
                parfor session = 1:n_sessions
                  result_mat = [result_mat pct.simulations.pit_strategies( ...
                    m1_strategy, m2_strategy, m1_error_rate, m2_error_rate, ...
                    choice_prob_list, m1_win_prob, coop_reward, max_moves, ...
                    n_reps, num_patches, session)];
                end
              end
            end
          end
        end
      end
    end
  end
end

if save_data_flag
  legend = 'each trial is a struct with details';
  data_filename = ['./+data/', 'pct-simulation-', ...
    'run-' datestr(datetime, 'yyyy-mm-dd_HH-MM-SS')];
  save(data_filename, 'result_mat', 'legend', 'strategy_list');
end