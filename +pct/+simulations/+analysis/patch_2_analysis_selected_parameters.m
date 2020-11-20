function patch_2_analysis_selected_parameters()
% To be run in cluster

data_folder = [pct.util.get_project_folder, ...
  '/+pct/+simulations/+data/', ...
  '2-patches-with-val-update-2020-05-13_20-19-19/'];

coop_reward = 1;
m1_error_rate = 0.1;
m2_error_rate = 0.1;

file_identifier = ['patches-2-coop-', num2str(100*coop_reward) , ...
  '-moves-*-m1win-*-m1err-', num2str(100*m1_error_rate),...
  '-m2err-', num2str(100*m2_error_rate), '.mat'];

files = dir([data_folder, file_identifier]);
dir([data_folder, file_identifier])

% strategy_list = {'selfish', 'competitive', 'interactive-compete', ...
%   'interactive-cooperate', 'benevolent', 'random', 'value-update-unchosen'...
%   'value-update-unrewarded'};

% if isempty(gcp('nocreate'))
%   parpool( feature('NumCores') );
% else
%   delete(gcp('nocreate'));
%   parpool( feature('NumCores') );
% end

max_moves = 2:4;
m1_win_prob = [0.3 0.5 0.7];

mean_reward_diff = cell(3,3);
stdev_reward_diff = cell(3,3);

for file_ind = 1:numel( files )
  data = load([data_folder, files(file_ind).name]);
  if file_ind == 1
    strategy_list = unique( { data.result_mat_across_strategies.m1_strategy } );
  end
  if abs(data.result_mat_across_strategies(1).m1_win_prob - 0.4) < 0.001
    disp(data.result_mat_across_strategies(1).m1_win_prob);
    disp(data.result_mat_across_strategies(1).m1_win_prob - 0.4)
    continue;
  end
  if abs(data.result_mat_across_strategies(1).m1_win_prob - 0.6) < 0.001
    disp(data.result_mat_across_strategies(1).m1_win_prob);
    disp(data.result_mat_across_strategies(1).m1_win_prob - 0.6);
    continue;
  end
  moves_ind = find( max_moves == data.result_mat_across_strategies(1).max_moves );
  disp(['moves_ind=', num2str(moves_ind)]);
  win_prob_ind = find( abs(m1_win_prob - data.result_mat_across_strategies(1).m1_win_prob) < 0.001 );
  disp(['win_prob_ind=', num2str(win_prob_ind)]);
  disp(data.result_mat_across_strategies(1).m1_win_prob);
  session_numbers = unique([ data.result_mat_across_strategies.session ]);
  total_reward_diff = nan(numel( strategy_list ), numel( strategy_list ), ...
    max(session_numbers));
  for m1_strat_ind = 1:numel( strategy_list )
    for m2_strat_ind = 1:numel( strategy_list )
      parfor session = session_numbers
        data_subset_ind = ...
          strcmp({ data.result_mat_across_strategies.m1_strategy }, ...
          strategy_list{m1_strat_ind}) & ...
          strcmp({ data.result_mat_across_strategies.m2_strategy }, ...
          strategy_list{m2_strat_ind}) & ...
          [ data.result_mat_across_strategies.session ] == session;
        data_subset = data.result_mat_across_strategies(data_subset_ind);
        reward_per_trial = sum([ data_subset.reward ]);
        total_m1_reward = sum( reward_per_trial(1:2:end) );
        total_m2_reward = sum( reward_per_trial(2:2:end) );
        total_reward_diff(m1_strat_ind, m2_strat_ind, session) = ...
          total_m1_reward - total_m2_reward;
      end
    end
  end
  mean_reward_diff{moves_ind, win_prob_ind} = mean(total_reward_diff, 3);
  stdev_reward_diff{moves_ind, win_prob_ind} = std(total_reward_diff, 0, 3);
  disp(['File ', num2str(file_ind) , ' done, of ', num2str(numel( files )) , ' files.']);
end

fname = [pct.util.get_project_folder, ...
    '/+pct/+simulations/+analysis/', ...
    '2-patches/2-patch_reward-diff-matrix', ...
    '_coop-reward-', num2str(coop_reward), ...
    '.mat'];
save(fname, 'mean_reward_diff', 'stdev_reward_diff', ...
  'strategy_list', 'm1_win_prob', 'max_moves');

for moves_ind = 1:3
  figure();
  for win_prob_ind = 1:3
    subplot( 1, 3, win_prob_ind );
    imagesc(mean_reward_diff{moves_ind, win_prob_ind});
    title(['M1 win prob = ', num2str(m1_win_prob(win_prob_ind))]);
  end
  suptitle(['2 patches: Max moves = ', num2str(max_moves(moves_ind))]);
  fname = [pct.util.get_project_folder, ...
    '/+pct/+simulations/+analysis/', ...
    '2-patches/2-patch_reward-diff_max-moves', ...
    num2str(max_moves(moves_ind)), '_coop-reward-', num2str(coop_reward)];
  exp_to_pdf(fname);
  close;
end

end
