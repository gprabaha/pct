classdef OnePatchOneReward_TrialSet
  
  methods
    function obj = OnePatchOneReward_TrialSet()
      %
    end

    function tt = generate_trial_set(obj)
      tt = generate_four_patch_trial_set_against_algo();
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

patch_types = {
 struct('reward_count', 1, 'acquirable_by', {{'m1'}}, 'strategy', 'self', 'agent', 'hitch') ...
 struct('reward_count', 1, 'acquirable_by', {{'m2'}}, 'strategy', 'self', 'agent', 'computer_naive_random') ...
 struct('reward_count', 1, 'acquirable_by', {{'m1', 'm2'}}, 'strategy', 'compete', 'agent', 'either') ...
 struct('reward_count', 1, 'acquirable_by', {{'m1', 'm2'}}, 'strategy', 'cooperate', 'agent', 'either') ...
};

end

function trial_set = generate_four_patch_trial_set_against_algo()

% Intialization assignments %

trial_set         = {};
patch_types       = get_patch_types();
idx               = 0;

% Patch list for each trial types %

% Forced reward inequity %

% Self-M1
idx = idx+1;
trial_set{idx} = [
  patch_types{1}
];

% Self-M2
idx = idx+1;
trial_set{idx} = [
  patch_types{2}
];

% Compete
idx = idx+1;
trial_set{idx} = [
  patch_types{3}
];

% Cooperate
idx = idx+1;
trial_set{idx} = [
  patch_types{4}
];

end