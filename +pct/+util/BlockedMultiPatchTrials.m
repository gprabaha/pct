classdef BlockedMultiPatchTrials < pct.util.EstablishPatchInfo
  % A class that fetches information about the possible types of trials
  % that can be presented, and then presents those trials in a pseudo
  % randomized order such that no two subsequent trials are the same.
  
  properties
    patch_types                         = { 'self', 'compete', 'cooperate' };
    default_patch_type                  = 'compete';
    block_counter                       = 0;
    trials_per_block                    = 10;
    trial_reps                          = 2;
    trial_ind                           = 0;
    trial_set                           = [];
    trial_order                         = [];
    current_trial_number                = nan;
    trial_set_generator                 = [];
    
    
    generate_new_trial_patches          = true; % for trial part 1
    collect_remaining_patches           = false; % for trial part 2
    
    
    next_trial_strategy                 = 'random'; % or 'sequential'
    last_patch_info                     = pct.util.PatchInfo.empty();
    persist_patch_info_until_exhausted  = false;
    max_num_trials_persist_patch_info   = 2;
    num_trials_persisted_patch_info     = 0;    
    next_set_id                         = 1;
    next_patch_id                       = 1;
    trial_sequence_id                   = 0;
    patch_sequence_index                = 1;
    
    repeat_wrong_trials_later           = true;
    prevent_consecutive_trial_repeat    = true;
    generate_trial_order_again          = false;
    presented_for_first_time            = false;
    presented_for_second_time           = false;
  end
  
  methods
    function obj = BlockedMultiPatchTrials(varargin)
      % Function initialize the default parameters of the class
      
      % Default assignments %
      
      defaults = struct();
      
      % Need to check with the 'pause' state for the 'trials_per_block'
      % parameter
      
      defaults.trial_reps                         = 2; % repeats of each trial
      defaults.trials_per_block                   = 50; % gets a break after 50 trials
      defaults.current_trial_number               = 1;
      defaults.patch_types                        = { 'self', 'compete', 'cooperate' };
      defaults.repeat_wrong_trials_later          = true;
      defaults.prevent_consecutive_trial_repeat   = true;
      defaults.max_num_trials_persist_patch_info  = 2;
      defaults.next_block_strategy                = [];   
      defaults.block_types                        = {};
      defaults.start_block_type                   = '';
      defaults.persist_patch_info_until_exhausted = false;
      defaults.max_num_trials_persist_patch_info  = 2;
      defaults.max_num_patches_acquireable_per_trial = 1;
      defaults.trial_set_generator                = pct.util.FourPatchTrialSet;
      
      
      % Operations for final assignment %
      
      params = shared_utils.general.parsestruct( defaults, varargin );
      
      obj.trial_reps                          = params.trial_reps;
      obj.trials_per_block                    = params.trials_per_block;
      obj.patch_types                         = params.patch_types;
      obj.repeat_wrong_trials_later           = params.repeat_wrong_trials_later;
      obj.prevent_consecutive_trial_repeat    = params.prevent_consecutive_trial_repeat;
      obj.max_num_trials_persist_patch_info   = params.max_num_trials_persist_patch_info;
      obj.trial_set_generator                 = params.trial_set_generator;
    end    
    
    % Generate all trials in order
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function trial_order = generate_trial_order(obj)
      % Generates an array containing an ordered list of all possible
      % trials. Then samples uniformly from that list without replacement,
      % while ensuring that no two consecutive trials are the same.
      
      % Initial assignments %
      
      obj.generate_trial_order_again    = false;
      num_trial_types                   = numel(obj.trial_set);
      n_reps                            = obj.trial_reps;
      trial_order                       = nan(n_reps*num_trial_types,1);
      
      % Operations %
      
      % Generate list of all trials
      trial_stack = repmat( (1:num_trial_types)', [1 n_reps] );
      trial_stack = trial_stack(:);
      % Keep sampling from trial_stack until it is empty
      trial_order_idx = 1;
      while ~isempty( trial_stack )
        trial_sample = randsample( trial_stack, 1 );
        % Store the first trial irrespectively
        if trial_order_idx == 1
          trial_order(trial_order_idx) = trial_sample;
          trial_stack(find( trial_stack == trial_sample, 1 )) = [];
        % Check for repeats from next trial onwards
        else
          if trial_sample ~= trial_order(trial_order_idx-1)
            trial_order(trial_order_idx) = trial_sample;
            trial_stack(find( trial_stack == trial_sample, 1 )) = [];
          % If this sample matches the previous one, sample again for a few
          % times. Here I am sampling as many times as the number of
          % elements in the trial_stack.
          else
            num_remaining_trials = numel(trial_stack);
            if num_remaining_trials > 1
              counter = 0; 
              while ( trial_sample == trial_order(trial_order_idx-1) && ...
                  counter < num_remaining_trials )
                trial_sample = randsample( trial_stack, 1 );
                counter = counter+1;
              end
            else
              trial_sample = trial_stack(1);
            end
            % If still it does not find a solution, try again!
            if trial_sample == trial_order(trial_order_idx-1)
              disp('This attempt failed! Trying to generate trial-order without repeats again!');
              trial_order = obj.generate_trial_order();
              break;
            else
              trial_order(trial_order_idx) = trial_sample;
              trial_stack(find( trial_stack == trial_sample, 1 )) = [];
            end
          end
        end
        trial_order_idx = trial_order_idx+1;
      end
      obj.trial_order = trial_order;  
    end
    
    % Check if this is the second presentation of the patches
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function tf = is_second_presentation(obj)
      % Function to check of this is the second part of the trial and thus
      % if the patch info needs to be persisted
      
      % Initial assignment %
      
      tf = false;
      
      % Operations %
      
      if( obj.presented_for_first_time && ~obj.presented_for_second_time )
        tf = true;
      end
    end
    
    % Should next trial info be fetched?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function tf = get_new_trial_info(obj, program)
      % Function to determine if patch information pertaining to the next
      % trial need to be procured
      
      % Initial assignments %
      
      tf            = false;
      trial_data    = program.Value.data.Value;
      
      % Operations %
      
      % Check if this is the first trial
      if ( isempty(trial_data) )
        tf = true;
        return
      end
      
      % Check if current number of patches is not the same as the initial
      % number of patches whiich would imply that the second part of the
      % trial has been reached
      if ( obj.is_second_presentation )
        return
      end
      
      % Check if the last trial was initiated
      last_trial_data = trial_data(end);
      % Note this stage is called 'fixation' because it is the first
      % fixation at the beginning of a trial
      did_initiate_last_trial = last_trial_data.fixation.did_fixate;
      tf = did_initiate_last_trial;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HOW DO WE END THE TASK AFTER ALL TRIALS ARE OVER?? %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function [patch_info, patch_sequence_index] = generate(obj, patch_targets, program)
      
      % Initial assignments %
      
      latest_acquired_patches   = get_latest_acquired_patches( program );
      appearance_func           = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches               = numel( patch_targets );
      sequence_id               = obj.trial_sequence_id;
      if isempty(obj.trial_set)
        obj.trial_set           = obj.trial_set_generator.generate_trial_set();
      end
      if isempty(obj.trial_order)
        obj.trial_order         = obj.generate_trial_order();
      end
      
      % Operations %
      
      if( obj.get_new_trial_info(program) )
        obj.patch_sequence_index = 1; % first presentation.
        
        sequence_id = sequence_id + 1;
        obj.trial_sequence_id = sequence_id;
        trial_type_id = obj.trial_order(sequence_id);
        trial_patches = obj.trial_set{trial_type_id};
        
        radius = program.Value.patch_distribution_radius;
        rect = program.Value.window.Rect;
        coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );

        patch_info = pct.util.PatchInfo.empty();
        
        for i = 1:num_patches
          new_patch_info                = pct.util.PatchInfo();
          new_patch_info.AcquirableBy   = trial_patches(i).acquirable_by;
          new_patch_info.Agent          = trial_patches(i).agent;
          new_patch_info.Strategy       = trial_patches(i).block_type;  % change this to strategy.
          new_patch_info.Position       = coordinates(:, i);
          new_patch_info.Target         = patch_targets{i};
          new_patch_info.Index          = i;
          new_patch_info.ID             = obj.next_patch_id;
          new_patch_info.TrialTypeID    = trial_type_id;
          new_patch_info.SequenceID     = sequence_id;
          
          % Configure color, and other appearence properties.
          new_patch_info = appearance_func( new_patch_info );
          patch_info(end+1) = new_patch_info;
          obj.next_patch_id = obj.next_patch_id + 1;
        end
        obj.last_patch_info = patch_info;
        obj.presented_for_first_time = true;
        obj.presented_for_second_time = false;
        obj.num_trials_persisted_patch_info = 1;
        
      elseif( obj.is_second_presentation() )
        last_info = obj.last_patch_info;
        patch_info = filter_non_acquired_patches( last_info, latest_acquired_patches );
        obj.last_patch_info = patch_info;
        obj.presented_for_second_time = true;
        obj.patch_sequence_index = 2; % second presentation.
        
      else % The previous trial was not initiated so the monkeys did not see the patches
        patch_info = obj.last_patch_info;
      end
      
      patch_sequence_index = obj.patch_sequence_index;
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

% Inititl assignments %

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