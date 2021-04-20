classdef OnePatchManyReward_TrialSet
  
    methods
    function obj = OnePatchManyReward_TrialSet()
      %
    end

    function tt = generate_trial_set(obj)
      tt = genOnePatchManyRewardVsAlgo();
    end
    
    function patch_info = patch_appearance(obj, patch_info)      
      patch_info = pct.util.default_patch_appearance( patch_info );
    end
    
    function patch_types = fetch_patch_types(obj)
      patch_types = get_patch_types();
    end
  end
  
end


function patch_types = get_patch_types()

% Function defining the properties of possible types of patches
patch_types = cell(4,3);
for reward_count = 1:3
  patch_types_reward_count = {
     struct('reward_count', reward_count, 'acquirable_by', {{'m1'}}, 'strategy', 'self', 'agent', 'hitch') ...
     struct('reward_count', reward_count, 'acquirable_by', {{'m2'}}, 'strategy', 'self', 'agent', 'computer_naive_random') ...
     struct('reward_count', reward_count, 'acquirable_by', {{'m1', 'm2'}}, 'strategy', 'compete', 'agent', 'either') ...
     struct('reward_count', reward_count, 'acquirable_by', {{'m1', 'm2'}}, 'strategy', 'cooperate', 'agent', 'either') ...
    };
  patch_types(:,reward_count) = patch_types_reward_count;
end

end


function trial_set = genOnePatchManyRewardVsAlgo()

% Intialization assignments %
trial_set         = {};
patch_types       = get_patch_types();
idx               = 0;

% Self-M1 all rewards
self_m1_ind = 1;
for reward_count = 1:3
  idx = idx+1;
  trial_set{idx} = [
    patch_types{self_m1_ind,reward_count}
  ];
end

% Self-M2 all rewards
self_m2_ind = 2;
for reward_count = 1:3
  idx = idx+1;
  trial_set{idx} = [
    patch_types{self_m2_ind,reward_count}
  ];
end

% Compete all rewards
compete_ind = 3;
for reward_count = 1:3
  idx = idx+1;
  trial_set{idx} = [
    patch_types{compete_ind,reward_count}
  ];
end

% Cooperate all rewards
cooperate_ind = 4;
for reward_count = 1:3
  idx = idx+1;
  trial_set{idx} = [
    patch_types{cooperate_ind,reward_count}
  ];
end

end