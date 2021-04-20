function simulation_data = run_RL_simulation_dyadic_foraging()

% Assign the different patch types
choice_types = { ...
  'competition', ...
  'cooperation' ...
  };
% Probability of M1 winning a competition patch
comp_win_probabilities = [0.3 0.5 0.7];
% RL value update strategies for M1
m1_rl_strategies = { ...
  'self_chosen', ...
  'self_unchosen', ...
  'both_chosen', ...
  'both_unchosen' ...
  };
% Choice preference for M2
m2_strategies = { ...
  'random', ...
  'competitive', ...
  'cooperative'...
  };
% Relative reward for competition vs cooperation
% Row 1: competition
% Row 2: cooperation
reward_pair_array = [ ...
  1 1 1 2 2 2 3 3 3; ...
  1 2 3 1 2 3 1 2 3; ...
  ];
% Number of repeats of each reward-pair
n_reps = 100;
% Number of simulation run for each condition
n_sessions = 50;

% Parameters of RL modeling. Values motivated by Ito and Doya, 2009,
% JNeurosci
rl_parameters = struct();
rl_parameters.alpha_chosen = 0.6;
rl_parameters.alpha_unchosen = 0.8;
rl_parameters.k_chosen_rewarded = 1.2;
rl_parameters.k_chosen_unrewarded = 1.5;
rl_parameters.k_unchosen = 1;
rl_parameters.delta = 0.5;

% Initiate the cell to store data
simulation_data = cell( ...
  numel(m1_rl_strategies), ...
  numel(m2_strategies), ...
  numel(comp_win_probabilities), ...
  numel(n_sessions) ...
  );

for rl_strategy_idx = 1:numel(m1_rl_strategies)
  for m2_strategy_idx = 1:numel(m2_strategies)
    for win_prob_idx = 1:numel(comp_win_probabilities)
      m1_strategy = m1_rl_strategies{rl_strategy_idx};
      m2_strategy = m2_strategies{m2_strategy_idx};
      comp_win_prob = comp_win_probabilities(win_prob_idx);
      disp('Running for the case:');
      disp(['M1_Strategy=', m1_strategy, '; M2_strategy=', m2_strategy, ...
          '; comp_win_prob=', num2str(comp_win_prob)]);
      for session = 1:n_sessions
        simulation_data{rl_strategy_idx, m2_strategy_idx, win_prob_idx, session} = run_rl_simulation( rl_parameters, m1_strategy, ...
          m2_strategy, comp_win_prob, choice_types, reward_pair_array,  n_reps );
      end
    end
  end
end

timestamp = datestr(datetime('now'));
timestamp([12 15 18]) = '-';
filename = ['rl_simulation_run_' timestamp '.mat'];
save(filename, 'simulation_data');

end

function trial_array = generate_trial_array(reward_pair_array, n_reps)

% Generates comp vs coop reward amount for each trial
trial_array = [];
for rep_ind = 1:n_reps
  indices = 1:size( reward_pair_array, 2 );
  shuffled_indices = Shuffle(indices);
  trial_rep = reward_pair_array( : , shuffled_indices);
  trial_array = [ trial_array trial_rep ];
end

end

function simulation_data = run_rl_simulation(rl_parameters, m1_strategy, m2_strategy, ...
  comp_win_prob, choice_types, reward_pair_array, n_reps)

% Initiate the various arrays involved
simulation_data = struct();
available_choices = 1:numel(choice_types);
trial_reward_pair_array = generate_trial_array( reward_pair_array, n_reps );
initial_values = rand( numel(choice_types), 1 );
value_array_rl = nan( 2, size( trial_reward_pair_array, 2 ) );
choice_array_rl = nan( 2, size( trial_reward_pair_array, 2 ) );
reward_array_rl = zeros( 2, size( trial_reward_pair_array, 2 ) );
choice_array_random = nan( 2, size( trial_reward_pair_array, 2 ) );
reward_array_random = zeros( 2, size( trial_reward_pair_array, 2 ) );

for trial_ind = 1:size( trial_reward_pair_array, 2 )
  % Assign the initial values randomly
  if trial_ind == 1
    value_array_rl( :, trial_ind ) = initial_values;
  else
    % Update values based on previous values and specific RL algo
    value_array_rl( :, trial_ind ) = update_value( rl_parameters, m1_strategy, ...
      value_array_rl( :, trial_ind-1 ), choice_array_rl( :, trial_ind-1 ), ...
      reward_array_rl( :, trial_ind-1 ) );
  end
  % Find the values of patch choices
  values = value_array_rl( :, trial_ind );
  % Weighing the values by reward amount
  values = values.*trial_reward_pair_array( :, trial_ind );
  % Converting vlalues to probabilities
  choice_probabilities = softmax(values);
  % RL
  m1_choice_rl = randsample( available_choices, 1, true, choice_probabilities );
  % Make M2's choice according to strategy
  m2_choice_rl = get_m2_choice( available_choices, m2_strategy );
  % Update the choice made by each
  choice_array_rl(1, trial_ind) = m1_choice_rl;
  choice_array_rl(2, trial_ind) = m2_choice_rl;
  % Distribute reward according to choices
  reward_array_rl(:, trial_ind) = assign_reward( choice_array_rl(:, trial_ind), ...
    trial_reward_pair_array(:, trial_ind), comp_win_prob );
  % Generate same data for M1's random choice instead of RL
  choice_array_random(1, trial_ind) = randsample( available_choices, 1 );
  choice_array_random(2, trial_ind) = get_m2_choice( available_choices, m2_strategy );
  reward_array_random(:, trial_ind) = assign_reward( choice_array_random(:, trial_ind), ...
    trial_reward_pair_array(:, trial_ind), comp_win_prob );
end

simulation_data.m1_strategy = m1_strategy;
simulation_data.m2_strategy = m2_strategy;
simulation_data.rl_parameters = rl_parameters;
simulation_data.comp_win_prob = comp_win_prob;
simulation_data.trial_reward_pair_array = trial_reward_pair_array;
simulation_data.value_array_rl = value_array_rl;
simulation_data.choice_array_rl = choice_array_rl;
simulation_data.reward_array_rl = reward_array_rl;
simulation_data.choice_array_random = choice_array_random;
simulation_data.reward_array_random = reward_array_random;
      
end

function current_value = update_value(rl_parameters, m1_strategy, previous_value, prev_choice_rl, prev_reward_rl)

% Update the value of competition (1) and cooperation (2) patches according
% to the specific RL algorithm being used
alpha_chosen = rl_parameters.alpha_chosen;
alpha_unchosen = rl_parameters.alpha_unchosen;
k_chosen_rewarded = rl_parameters.k_chosen_rewarded;
k_chosen_unrewarded = rl_parameters.k_chosen_unrewarded;
k_unchosen = rl_parameters.k_unchosen;
delta = rl_parameters.delta;

choice = prev_choice_rl(1);
if choice == 1
  unchoice = 2;
else
  unchoice = 1;
end
reward = prev_reward_rl(1);
current_value = previous_value;

switch m1_strategy
  case 'self_chosen'
    if reward > 0
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) + alpha_chosen*k_chosen_rewarded;
    else
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) - alpha_chosen*k_chosen_unrewarded;
    end
    current_value(unchoice) = (1-alpha_unchosen)*previous_value(unchoice);
  case 'self_unchosen'
    if reward > 0
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) + alpha_chosen*k_chosen_rewarded;
    else
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) - alpha_chosen*k_chosen_unrewarded;
    end
    current_value(unchoice) = (1-alpha_unchosen)*previous_value(unchoice) + alpha_unchosen*k_unchosen;
  case 'both_chosen'
    if reward > 0
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) + alpha_chosen*k_chosen_rewarded;
    else
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) - alpha_chosen*k_chosen_unrewarded;
    end
    current_value(unchoice) = (1-alpha_unchosen)*previous_value(unchoice);
    if prev_choice_rl(2) == 1
      current_value(1) = current_value(1) - delta;
    else
      current_value(2) = current_value(2) + delta;
    end
  case 'both_unchosen'
    if reward > 0
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) + alpha_chosen*k_chosen_rewarded;
    else
      current_value(choice) = (1-alpha_chosen)*previous_value(choice) - alpha_chosen*k_chosen_unrewarded;
    end
    current_value(unchoice) = (1-alpha_unchosen)*previous_value(unchoice) + alpha_unchosen*k_unchosen;
    if prev_choice_rl(2) == 1
      current_value(1) = current_value(1) - delta;
    else
      current_value(2) = current_value(2) + delta;
    end
end

end

function m2_choice = get_m2_choice(choices, m2_strategy)

% Make probabilistic choices for M2
switch m2_strategy
  case 'random'
    m2_choice = randsample(choices, 1);
  case 'competitive'
    m2_choice = randsample(choices, 1, true, [0.7 0.3]);
  case 'cooperative'
    m2_choice = randsample(choices, 1, true, [0.3 0.7]);
end

end

function reward_amount = assign_reward(choices_made, reward_array, comp_win_prob)

% Distribute reward according to the choices of the agents
reward_amount = nan(2, 1);
if choices_made(1) == 1
  if choices_made(2) == 1
    if rand <= comp_win_prob
      reward_amount(1) = reward_array(1);
      reward_amount(2) = 0;
    else
      reward_amount(2) = reward_array(1);
      reward_amount(1) = 0;
    end
  else
    reward_amount(1) = reward_array(1);
    reward_amount(2) = 0;
  end
else
  if choices_made(2) == 1
    reward_amount(2) = reward_array(1);
    reward_amount(1) = 0;
  else
    reward_amount(1) = reward_array(2);
    reward_amount(2) = reward_array(2);
  end
end

end
