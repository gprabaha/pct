function analyze_rl_simulation_data(simulation_data)

if nargin < 1
  available_files = dir('*.mat');
  file_ind = randsample( 1:numel(available_files), 1 );
  simulation_data = load(available_files(end).name);
  simulation_data = simulation_data.simulation_data;
end

choice_types = { ...
  'competition', ...
  'cooperation' ...
  };
m1_rl_strategies = { ...
  'self_chosen', ...
  'self_unchosen', ...
  'both_chosen', ...
  'both_unchosen' ...
  };
m2_strategies = { ...
  'random', ...
  'competitive', ...
  'cooperative'...
  };
comp_win_probabilities = [0.3 0.5 0.7];

for m1_strategy_idx = 1:size(simulation_data, 1)
  for m2_strategy_idx = 1:size(simulation_data, 2)
    for win_prob_idx = 1:size(simulation_data, 3)
      % Total reward
      session_data = squeeze(simulation_data(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :));
      reward_summary_rl(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :, :) = nan(2,2);
      total_reward_rl = nan(2, numel(session_data));
      reward_summary_random(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :, :) = nan(2,2);
      total_reward_random = nan(2, numel(session_data));
      m1_reward_prob = [];
      m1_reward_prob_rand = [];
      for session = 1:numel(session_data)
        total_reward_rl(:, session) = sum( session_data{session}.reward_array_rl, 2 );
        total_reward_random(:, session) = sum( session_data{session}.reward_array_random, 2 );
        % Probability of reward
        m1_did_get_rewarded = (session_data{session}.reward_array_rl>0);
        m1_did_get_rewarded_rand = (session_data{session}.reward_array_random>0);
        m1_did_get_rewarded = m1_did_get_rewarded(1,:);
        m1_did_get_rewarded_rand = m1_did_get_rewarded_rand(1,:);
        m1_reward_prob = [m1_reward_prob; m1_did_get_rewarded];
        m1_reward_prob_rand = [m1_reward_prob_rand; m1_did_get_rewarded_rand];
      end
      m1_reward_prob = mean(m1_reward_prob);
      m1_reward_prob_rand = mean(m1_reward_prob_rand);
      choice_reward_prob(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :) = m1_reward_prob;
      choice_reward_prob_rand(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :) = m1_reward_prob_rand;
      mean_reward_rl = nanmean( total_reward_rl, 2 );
      sem_reward_rl = nanstd( total_reward_rl, 0, 2 )/sqrt(length(total_reward_rl));
      [h_rl, p_rl] = ttest2( total_reward_rl(1,:), total_reward_rl(2,:) );
      reward_comp_rl(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :) = [h_rl, p_rl];
      reward_summary_rl(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :, :) = [mean_reward_rl, sem_reward_rl];
      mean_reward_random = nanmean( total_reward_random, 2 );
      sem_reward_random = nanstd( total_reward_random, 0, 2 )/sqrt(length(total_reward_random));
      [h_rand, p_rand] = ttest2( total_reward_random(1,:), total_reward_random(2,:) );
      reward_comp_random(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :) = [h_rand, p_rand];
      reward_summary_random(m1_strategy_idx, m2_strategy_idx, win_prob_idx, :, :) = [mean_reward_random, sem_reward_random];
      
    end
  end
end


% Total reward
for win_prob_idx = 1:size(simulation_data, 3)
  m1_comp_win_prob = comp_win_probabilities(win_prob_idx);
  fig = figure();
  for m2_strategy_idx = 1:size(simulation_data, 2)
    m2_strategy = m2_strategies{m2_strategy_idx};
    means = squeeze(reward_summary_rl(:, m2_strategy_idx, win_prob_idx, :, 1));
    errors = squeeze(reward_summary_rl(:, m2_strategy_idx, win_prob_idx, :, 2));
    subplot(1, size(simulation_data, 2), m2_strategy_idx);
    barweb(means, errors, [], m1_rl_strategies);
    ylabel('Total reward');
    xtickangle(30);
    title(['M2 strategy = ' m2_strategy]);
  end
  suptitle(['M1 win prob for comp patch = ' num2str(m1_comp_win_prob)]);
  filename = ['total_reward_comp_win_prob' num2str(10*m1_comp_win_prob) ];
  saveas(fig, filename, 'pdf');
  close();
end

% Probability of getting a reward
for win_prob_idx = 1:size(simulation_data, 3)
  m1_comp_win_prob = comp_win_probabilities(win_prob_idx);
  fig = figure();
  for m2_strategy_idx = 1:size(simulation_data, 2)
    m2_strategy = m2_strategies{m2_strategy_idx};
    reward_prob = squeeze(choice_reward_prob(:, m2_strategy_idx, win_prob_idx, :));
    reward_prob_rand = squeeze(choice_reward_prob(2, m2_strategy_idx, win_prob_idx, :));
    all_reward_prob = [reward_prob; reward_prob_rand'];
    all_reward_prob = all_reward_prob';
    subplot(size(simulation_data, 2), 1, m2_strategy_idx);
    plot(all_reward_prob);
    legend([m1_rl_strategies 'random']);
    ylabel('Probability of choice being rewarded');
    xlabel('Trial number')
    title(['M2 strategy = ' m2_strategy]);
  end
  suptitle(['M1 win prob for comp patch = ' num2str(m1_comp_win_prob)]);
  filename = ['reward_probability_of_choice_comp_win_prob_' num2str(10*m1_comp_win_prob) ];
  saveas(fig, filename, 'pdf');
  close();
end

end