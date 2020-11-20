function anayze_strategy_interactions_2_patch()

files = dir('../+data/2-patches*');

data = load(['../+data/' files(1).name]);

strategy_list = data.strategy_list;
results = data.result_mat;

n_trials = size( results{1, 1, 1}.reward_queue, 2 );
n_sessions = size(results, 3);
n_strategies = numel(strategy_list);
m1_cumulative_reward = nan( n_strategies, n_strategies, n_sessions, n_trials );
m2_cumulative_reward = nan( n_strategies, n_strategies, n_sessions, n_trials );

counter = 0;
fig = figure('units','normalized','outerposition',[0 0 1 1]);
for m1_strategy_ind = 1:n_strategies
  for m2_strategy_ind = 1:n_strategies
    counter = counter + 1;
    subplot(n_strategies, n_strategies, counter);
    hold on;
    for session = 1:n_sessions
      reward_queue = results{m1_strategy_ind, m2_strategy_ind, session}.reward_queue;
      reward_queue = squeeze( sum( reward_queue, 1 ) );
      cumulative_reward_queue = cumsum( reward_queue );
      m1_cumulative_reward(m1_strategy_ind, m2_strategy_ind, ...
        session, :) = cumulative_reward_queue(:,1);
      m2_cumulative_reward(m1_strategy_ind, m2_strategy_ind, ...
        session, :) = cumulative_reward_queue(:,2);
      plot( cumulative_reward_queue(:,1), 'r' );
      plot( cumulative_reward_queue(:,2), 'g' );
      sub_plot_title = { ['M1: ' strategy_list{m1_strategy_ind}]; ...
        ['M2: ' strategy_list{m2_strategy_ind}] };
      title(sub_plot_title);
    end
    hold off;
  end
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Total cumulative reward');
xlabel(han,'Number of trials');
suptitle('2-patch: Cumulative rewards for strategy-pairs');

fname = '2-patch-cumulative-reward';
exp_to_pdf(fname);
close;


end