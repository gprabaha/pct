function [patches_acquired, reward] = distribute_rewards(patches, ...
  current_reward, acquired_patches, m1_win_prob, coop_reward, ...
  m1_patch_choice, m2_patch_choice)

% Patch legend
%
% 1 -> Self m1
% 2 -> Self m2
% 3 -> Competition
% 4 -> Cooperation

patches_acquired = acquired_patches;

for patch = 1:numel(m1_patch_choice)
  
  if m1_patch_choice(patch) == 1
    patch_chosen = patches(patch);
    
    if ~patches_acquired(patch)
    
      switch patch_chosen

        case 1
          current_reward(patch, 1) = current_reward(patch, 1) + 1;
          patches_acquired(patch) = 1;

        case 2
          current_reward(patch, 1) = current_reward(patch, 1);

        case 3
          if m2_patch_choice(patch) == 0
            current_reward(patch, 1) = current_reward(patch, 1) + 1;
            patches_acquired(patch) = 1;
          else
            if rand < m1_win_prob
              current_reward(patch, 1) = current_reward(patch, 1) + 1;
            else
              current_reward(patch, 2) = current_reward(patch, 2) + 1;
            end
            patches_acquired(patch) = 1;
          end

        case 4
          if m2_patch_choice(patch) == 1
            current_reward(patch, 1) = current_reward(patch, 1) + coop_reward;
            current_reward(patch, 2) = current_reward(patch, 2) + coop_reward;
            patches_acquired(patch) = 1;
          end
      end
    end
  end
end

for patch = 1:numel(m2_patch_choice)
  
  if m2_patch_choice(patch) == 1
    patch_chosen = patches(patch);
    
    if ~acquired_patches(patch)
      
      if patch_chosen < 4

        switch patch_chosen

          case 1
            current_reward(patch, 2) = current_reward(patch, 2);

          case 2
            current_reward(patch, 2) = current_reward(patch, 2) + 1;
            patches_acquired(patch) = 1;

          case 3
            if m1_patch_choice(patch) == 0
              current_reward(patch, 2) = current_reward(patch, 2) + 1;
              patches_acquired(patch) = 1;
            end
        end
      end
    end
  end
end

reward = current_reward;

end