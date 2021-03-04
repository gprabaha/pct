classdef FourPatchTrialSet
  %{
  
  properties (Constant = true)    
    possible_trial_types = {trial_type1, trial_type2, trial_type3};
  end
  
  %}
    
  methods
    function obj = FourPatchTrialSet()
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
 struct('acquirable_by', {{'m1'}}, 'strategy', 'self', 'agent', 'hitch') ...
 struct('acquirable_by', {{'m2'}}, 'strategy', 'self', 'agent', 'computer_naive_random') ...
 struct('acquirable_by', {{'m1', 'm2'}}, 'strategy', 'compete', 'agent', 'either') ...
 struct('acquirable_by', {{'m1', 'm2'}}, 'strategy', 'cooperate', 'agent', 'either') ...
};

end

function trial_set = only_m1_self()

patch_type = ...
  struct('acquirable_by', {{'m1'}}, 'strategy', 'self', 'agent', 'hitch');

trial_set = [patch_type, patch_type, patch_type, patch_type];
trial_set = repmat( {trial_set}, 4, 1 );

end

function trial_set = generate_four_patch_trial_set_against_algo()

% Intialization assignments %

trial_set         = {};
patch_types       = get_patch_types();
idx               = 0;

% Patch list for each trial types %

% Forced reward inequity %

% 1
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{1} ...
  patch_types{2} ...
];

% 2
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{2} ...
  patch_types{2} ...
];

% 3
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{2} ...
  patch_types{2} ...
];

%{
% Self and Competition %

% 4
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{2} ...
  patch_types{3} ...
];

% 5
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{3} ...
  patch_types{3} ...
];

% 6
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{3} ...
  patch_types{3} ...
];

% 7
idx = idx+1;
trial_set{idx} = [
  patch_types{2} ...
  patch_types{2} ...
  patch_types{3} ...
  patch_types{3} ...
];

% 8
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{2} ...
  patch_types{3} ...
];

% Self and Cooperation %

% 9
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{2} ...
  patch_types{4} ...
];

% 10
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{4} ...
  patch_types{4} ...
];

% 11
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{4} ...
  patch_types{4} ...
];

% 12
idx = idx+1;
trial_set{idx} = [
  patch_types{2} ...
  patch_types{2} ...
  patch_types{4} ...
  patch_types{4} ...
];

% 13
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{2} ...
  patch_types{4} ...
];

% Self, Competition, and Cooperation %

% 14
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{1} ...
  patch_types{3} ...
  patch_types{4} ...
];

% 15
idx = idx+1;
trial_set{idx} = [
  patch_types{1} ...
  patch_types{2} ...
  patch_types{3} ...
  patch_types{4} ...
];

% 16
idx = idx+1;
trial_set{idx} = [
  patch_types{2} ...
  patch_types{2} ...
  patch_types{3} ...
  patch_types{4} ...
];


% Competition and Cooperation %

% 17
idx = idx+1;
trial_set{idx} = [
  patch_types{3} ...
  patch_types{3} ...
  patch_types{3} ...
  patch_types{4} ...
];

% 18
idx = idx+1;
trial_set{idx} = [
  patch_types{3} ...
  patch_types{3} ...
  patch_types{4} ...
  patch_types{4} ...
];

% 19
idx = idx+1;
trial_set{idx} = [
  patch_types{3} ...
  patch_types{4} ...
  patch_types{4} ...
  patch_types{4} ...
];

% Pure competition %

% 20
idx = idx+1;
trial_set{idx} = [
  patch_types{3} ...
  patch_types{3} ...
  patch_types{3} ...
  patch_types{3} ...
];

% 21
idx = idx+1;
trial_set{idx} = [
  patch_types{4} ...
  patch_types{4} ...
  patch_types{4} ...
  patch_types{4} ...
];
%}
end