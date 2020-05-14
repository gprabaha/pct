function patch_choice = apply_strategy(monkey_identity, strategy, ...
  choice_prob_list, updated_patch_value_unchosen, ...
  updated_patch_value_unrewarded, error_rate, patches, acquired_patches)

available_patch_indices = acquired_patches==0;
available_choices = unique( patches(available_patch_indices) );
self_patch = monkey_identity;
competition = 3;
cooperation = 4;

switch strategy
  
  case 'selfish'
    preference_order = [self_patch competition cooperation];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'competitive'
    preference_order = [competition self_patch cooperation];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'interactive-compete'
    preference_order = [competition cooperation self_patch];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'interactive-cooperate'
    preference_order = [cooperation competition self_patch];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'benevolent'
    preference_order = [cooperation self_patch competition];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'random'
    preference_order = [self_patch competition cooperation];
    choice_prob_list = [1/3 1/3 1/3];
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'value-update-unchosen'
    preference_order = [self_patch competition cooperation];
    if self_patch == 1
      updated_patch_value_unchosen = updated_patch_value_unchosen([1, 3, 4]);
    else
      updated_patch_value_unchosen = updated_patch_value_unchosen([2, 3, 4]);
    end
    choice_prob_list = updated_patch_value_unchosen/sum(updated_patch_value_unchosen);
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
    
  case 'value-update-unrewarded'
    preference_order = [self_patch competition cooperation];
    if self_patch == 1
      updated_patch_value_unrewarded = updated_patch_value_unrewarded([1, 3, 4]);
    else
      updated_patch_value_unrewarded = updated_patch_value_unrewarded([2, 3, 4]);
    end
    choice_prob_list = updated_patch_value_unrewarded/sum(updated_patch_value_unrewarded);
    patch_choice = get_choice(preference_order, choice_prob_list, ...
      available_choices, patches, error_rate, acquired_patches);
end

end

function choice = get_choice(preference_order, choice_prob_list, ...
    available_choices, patches, error_rate, acquired_patches)

choice = zeros( numel(patches), 1 );
if any( ismember(available_choices, preference_order) )
  [~, choice_indices] = ismember(available_choices, preference_order);
  choice_indices = unique( choice_indices(choice_indices>0) );
  if numel( choice_indices ) == 1
    patch_selected = preference_order(choice_indices);
  else
    probabilities = choice_prob_list(choice_indices);
    probabilities = probabilities/sum(probabilities);
    patch_selected = randsample(preference_order(choice_indices), 1, true, probabilities);
  end
  if rand < error_rate
    patch_selected = 0;
  end
else
  patch_selected = 0;
end

if patch_selected ~= 0
  selected_patch_ind = find(patches==patch_selected & acquired_patches==0);
  if numel(selected_patch_ind) > 1
    prob_array = ones( 1, numel(selected_patch_ind) )/numel(selected_patch_ind);
    selected_patch_ind = randsample(selected_patch_ind, 1, true, prob_array);
  end
  choice(selected_patch_ind) = 1;
end
end