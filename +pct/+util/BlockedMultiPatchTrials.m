classdef BlockedMultiPatchTrials < pct.util.EstablishPatchInfo
  % A class that fetches information about the possible types of trials
  % that can be presented, and then presents those trials in a pseudo
  % randomized order such that no two subsequent trials are the same.
  
  properties
    patch_types                           = { 'self', 'compete', 'cooperate' };
    trial_reps                            = 10;
    trial_set                             = [];
    trial_order                           = [];
    trial_set_generator                   = [];
    last_patch_info                       = pct.util.PatchInfo.empty();
    next_set_id                           = 1;
    next_patch_id                         = 1;
    trial_index                           = 0;
    trial_sequence_id                     = 0;
    patch_sequence_id                     = 1;
    
    % Indicators %
    all_trials_over                       = false;
    generate_trial_order_again            = false;
    presented_for_first_time              = false;
    presented_for_second_time             = false;
    max_num_patches_acquireable_per_trial = 1;
  end
  
  methods
    function obj = BlockedMultiPatchTrials(varargin)
      % Function initialize the default parameters of the class
      
      % Initial assignments %
      
      defaults                                        = struct();
      defaults.trial_reps                             = 10; % repeats of each trial
      defaults.patch_types                            = { 'self', 'compete', 'cooperate' }; 
      defaults.max_num_patches_acquireable_per_trial  = 1;
      defaults.trial_set_generator                    = pct.util.FourPatchTrialSet;
      
      
      % Operations for final assignment %
      
      params = shared_utils.general.parsestruct( defaults, varargin );
      
      obj.trial_reps                            = params.trial_reps;
      obj.patch_types                           = params.patch_types;
      obj.max_num_patches_acquireable_per_trial = params.max_num_patches_acquireable_per_trial;
      
      if ( ~isempty(params.trial_set_generator) )
        obj.trial_set_generator = params.trial_set_generator;
      else
        obj.trial_set_generator = defaults.trial_set_generator;
      end
    end    
    
    % Update trial index if not second presentation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function trial_index  = update_trial_index(obj, program)
      % Function to update trial index unless it is the second presentation
      % of patches
      
      % Initial assignment %
      
      trial_index  = obj.trial_index;
      
      % Operations %
      
      if ( ~obj.is_second_presentation(program) )
        trial_index = trial_index + 1;
      end
    end
    
    % Generate all trials in order
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function trial_order = generate_trial_order(obj)
      
      % Initial assignments %
      
      num_trial_types   = numel(obj.trial_set);
      n_reps            = obj.trial_reps;
      trial_order       = [];
      
      % Operations %
      
      for rep = 1:n_reps
        % Generate temporary shuffled trial sequence
        temp_trial_seq = randperm(num_trial_types, num_trial_types);
        % Accept for the first rep
        if rep == 1
          trial_order = [trial_order temp_trial_seq];
        % For other reps  
        else
          % Check if the end of previous rep is same as the beginning of
          % the upcoming shuffled triel sequence
          if trial_order(end) ~= temp_trial_seq(1)
            trial_order = [trial_order temp_trial_seq];
          else
            while trial_order(end) == temp_trial_seq(1)
              temp_trial_seq = randperm(num_trial_types, num_trial_types);
            end
            trial_order = [trial_order temp_trial_seq];
          end
        end
      end
      
      obj.trial_order = trial_order;
    end
    
    % Check if this is the second presentation of the patches
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function tf = is_second_presentation(obj, program)
      % Function to check of this is the second part of the trial and thus
      % if the patch info needs to be persisted
      
      % Initial assignment %
      
      tf            = false;
    end
    
    % Should next trial info be fetched?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function tf = get_new_trial_info(obj, program)
      % Function to determine if patch information pertaining to the next
      % trial need to be procured
      
      % Initial assignments %
      
      tf            = true;
      trial_data    = program.Value.data.Value;
      
      % Operations %
      
      % Check if this is the first trial
      if ( isempty(trial_data) )
        return
      end
      
      last_trial_data = trial_data(end);
      did_initiate_last_trial = last_trial_data.fixation.did_fixate;
      
      if ( did_initiate_last_trial )
        return
      end
      
      % The last trial was not initiated, so reuse it.
      tf = false;
    end
    
    % Top-level function to fetch the information of the patches to display
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function [patch_info, trial_index, patch_sequence_id, all_trials_over] = ...
        generate(obj, patch_targets, program)
      
      % Initial assignments %
      
      patch_info                = pct.util.PatchInfo.empty();
      trial_data                = program.Value.data.Value;
      latest_acquired_patches   = get_latest_acquired_patches( program );
      all_trials_over           = obj.all_trials_over;
      trial_index               = obj.trial_index;
      appearance_func           = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches               = numel( patch_targets );
      sequence_id               = obj.trial_sequence_id;
      patch_sequence_id         = 0;
      
      if isempty(obj.trial_set) % For the first presentation
        obj.trial_set           = obj.trial_set_generator.generate_trial_set();
      else
 
      end
      if isempty(obj.trial_order)
        obj.trial_order         = obj.generate_trial_order();
      end
      
      % Operations %
      
      trial_index = obj.update_trial_index(program);
      obj.trial_index = trial_index;
      
      if( obj.get_new_trial_info(program) )
        obj.patch_sequence_id = 1; % first presentation.
        
        % Update trial sequence
        sequence_id = sequence_id + 1;
        obj.trial_sequence_id = sequence_id;
        
        % To end task when trials are over
        if( obj.trial_sequence_id > numel(obj.trial_order))
          all_trials_over = true;
          obj.all_trials_over = true;
          return;
        end
        
        % Fetch the list of patches
        trial_type_id = obj.trial_order(sequence_id);
        trial_patches = obj.trial_set{trial_type_id};
        
        % Extract patch info
        radius = program.Value.patch_distribution_radius;
        rect = program.Value.window.Rect;
        coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );
        get_acquired_face_color = program.Value.config.STRUCTURE.get_patch_acquired_face_color;
        
        for i = 1:num_patches
          new_patch_info                          = pct.util.PatchInfo();
          new_patch_info.AcquirableBy             = trial_patches(i).acquirable_by;
          new_patch_info.Agent                    = trial_patches(i).agent;
          new_patch_info.Strategy                 = trial_patches(i).strategy; %strategy; %block_type;  % change this to strategy.
          new_patch_info.Position                 = coordinates(:, i);
          new_patch_info.Target                   = patch_targets{i};
          new_patch_info.Index                    = i;
          new_patch_info.ID                       = obj.next_patch_id;
          new_patch_info.TrialTypeID              = trial_type_id;
          new_patch_info.SequenceID               = sequence_id;
          new_patch_info.GetAcquiredFaceColor     = get_acquired_face_color;
          
          % Configure color, and other appearence properties.
          new_patch_info = appearance_func( new_patch_info );
          patch_info(end+1) = new_patch_info;
          obj.next_patch_id = obj.next_patch_id + 1;
        end
        obj.last_patch_info = patch_info;
        obj.presented_for_first_time = true;
        obj.presented_for_second_time = false;
        
      else
        if( obj.is_second_presentation(program) )
          last_info = obj.last_patch_info;
          patch_info = filter_non_acquired_patches( last_info, latest_acquired_patches );
          obj.last_patch_info = patch_info;
          obj.presented_for_first_time = true;
          obj.presented_for_second_time = true;
          obj.patch_sequence_id = 2; % second presentation.
        
        else % The previous trial was not initiated so the monkeys did not see the patches
          obj.patch_sequence_id = 1;
          patch_info = obj.last_patch_info;
          obj.presented_for_first_time = true;
          obj.presented_for_second_time = false;
        end
      end
      
      patch_sequence_id = obj.patch_sequence_id;
    end
  end
 end

function acquired = get_latest_acquired_patches(program)

% Initial assignments %

trial_data = program.Value.data.Value;

% Operations %

if ( isempty(trial_data) )
  acquired = {};
else
  acquired = trial_data(end).just_patches.acquired_patches;
end

end

function remaining_patches = filter_non_acquired_patches(possible_patches, maybe_acquired_patches)

% Initial assignments %

acquired_patches = maybe_acquired_patches(cellfun(@(x) ~isempty(x), maybe_acquired_patches));
acquired_patches = vertcat( pct.util.PatchInfo.empty(), acquired_patches{:} );

% Operations %

possible_ids = [possible_patches.ID];
acquired_ids = [acquired_patches.ID];

was_acquired = ismember( possible_ids, acquired_ids );
remaining_patches = possible_patches(~was_acquired);

end

function id = logging_id()
id = 'BlockedMultiPatchTrials';
end