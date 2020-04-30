function patch_choice = apply_strategy(monkey_identity, strategy, ...
  choice_prob_list, error_rate, patches, acquired_patches)

available_patch_indices = acquired_patches==0;
self_patch = monkey_identity;
competition = 3;
cooperation = 4;

switch strategy
  
  case 'selfish'
    preference_order = [self_patch competition cooperation];
    available_choices = unique( patches(available_patch_indices) );
    if any(ismember(available_choices, preference_order))
      [~, choice_indices] = ismember(preference_order, available_choices);
      choice_indices = choice_indices(choice_indices>0);
      probabilities = choice_prob_list(choice_indices);
      probabilities = probabilities/sum(probabilities);
      patch_choice = randsample(preference_order, 1, true, probabilities);
    end
    
end