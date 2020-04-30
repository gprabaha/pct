function pit_strategies(m1_strategy, m2_strategy, coop_reward, n_reps, ...
        num_patches, save_data_flag, save_fig_flag)

% Validation of input parameters
if nargin<3
  error('Too few arguments. Need the strategies of m1 and m2');
end

if isempty(coop_reward)
  coop_reward = 0.5;
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
response_sequence = zeros( size( trial_sequence ) );

end