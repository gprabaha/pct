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
    
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forced reward (in)equity %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function patch_types = get_patch_types()

patch_types = {
 struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch') ...
 struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo') ...
 struct('acquireable_by', {{'m1', 'm2'}}, 'block_type', 'compete', 'agent', 'either') ...
 struct('acquireable_by', {{'m1', 'm2'}}, 'block_type', 'cooperate', 'agent', 'either') ...
};

end

function trial_set = generate_four_patch_trial_set_against_algo()

trial_set = {};
patch_types = get_patch_types();
disp(patch_types);
idx = 0;
% Forced reward inequity

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

% Self and Competition

% 4
% FILL IN THE REST

end

%{

function patches = trial_type1()

patches = {
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
};

end

function patches = trial_type2()

patches = {
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
};

end

function patches = trial_type3()

patches = {
  {struct('acquireable_by', {{'m1'}}, 'block_type', 'self', 'agent', 'hitch')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
  {struct('acquireable_by', {{'m2'}}, 'block_type', 'self', 'agent', 'algo')} ...
};

end

%}