classdef BlockedMultiPatchTrials < pct.util.EstablishPatchInfo
  properties
    patch_types                         = { 'self', 'compete', 'cooperate' };
    default_patch_type                  = 'compete';
    block_counter                       = 0;
    trials_per_block                    = 10;
    trial_reps                          = 2;
    trial_ind                           = 0;
    trial_set                           = [];
    trial_bag                           = [];
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
    repeat_wrong_trials_later           = true;
    prevent_consecutive_trial_repeat    = true;
    generate_trial_order_again          = false;
  end
  
  methods
    function obj = BlockedMultiPatchTrials(varargin)
      % New defaults
      defaults = struct();
      % Need to check with the 'pause' state for the 'trials_per_block'
      % parameter
      defaults.trial_reps                         = 2; % repeats of each trial
      defaults.trials_per_block                   = 50; % gets a break after 50 trials
      defaults.patch_types                        = { 'self', 'compete', 'cooperate' };
      defaults.repeat_wrong_trials_later          = true;
      defaults.prevent_consecutive_trial_repeat   = true;
      defaults.max_num_trials_persist_patch_info  = 2;
      defaults.trial_set_generator                = pct.util.FourPatchTrialSet;
      
      params = shared_utils.general.parsestruct( defaults, varargin );
      
      obj.trial_reps                          = params.trial_reps;
      obj.trials_per_block                    = params.trials_per_block;
      obj.patch_types                         = params.patch_types;
      obj.repeat_wrong_trials_later           = params.repeat_wrong_trials_later;
      obj.prevent_consecutive_trial_repeat    = params.prevent_consecutive_trial_repeat;
      obj.max_num_trials_persist_patch_info   = params.max_num_trials_persist_patch_info;
      obj.trial_set_generator                 = params.trial_set_generator;
      
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This has to made into something that selects the next trial %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function generate_randomized_trial_list(obj)
      %
    end
    
    %{
    
    function select_next_block_strategy(obj)
      if ( strcmp(obj.next_block_strategy, 'sequential') )
        % Select the next block type from `block_types`, wrapping back
        % around if necessary.
        obj.block_type_ind = obj.block_type_ind + 1;
        if ( obj.block_type_ind > numel(obj.block_types) )
          obj.block_type_ind = 1;
        end
      elseif ( strcmp(obj.next_block_strategy, 'random') )
        % randomly select a block types from `block_types`
        obj.block_type_ind = randi( numel(obj.block_types), 1 );
      end

      obj.block_type = obj.block_types{obj.block_type_ind};
    end
    
    %}
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This part controls the part1 and 2 of the trials %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function tf = update_patch_info_persist_patches(obj, ~, latest_acquired_patches, ~)
      % Generate new patches if there are no remaining non-acquired
      % patches, or if the number of trials over which we've persisted the
      % last patch set exceeds `max_num_trials_persist_patch_info`.
      remaining_non_acquired = filter_non_acquired_patches( obj.last_patch_info, latest_acquired_patches );
      
      num_persisted = obj.num_trials_persisted_patch_info;
      max_num_persit = obj.max_num_trials_persist_patch_info;
      
      tf = isempty( remaining_non_acquired ) || num_persisted >= max_num_persit;
    end
    
    function tf = update_patch_info_dont_persist_patches(obj, num_patches, ~, program)
      tf = true;
      
      if ( numel(obj.last_patch_info) ~= num_patches )
        return
      end
      
      trial_data = program.Value.data.Value;
      
      if ( isempty(trial_data) )
        return
      end
      
      % Reuse the last patch info if we didn't successfully initiate the
      % last trial, in which case the patch wouldn't have been seen.
      last_trial_data = trial_data(end);
      did_initiate_last_trial = last_trial_data.fixation.did_fixate;
      tf = did_initiate_last_trial;
    end
    
    function tf = generate_new_patch_info(obj, num_patches, latest_acquired_patches, program)
      if ( obj.persist_patch_info_until_exhausted )
        tf = obj.update_patch_info_persist_patches( num_patches, latest_acquired_patches, program );
      else
        tf = obj.update_patch_info_dont_persist_patches( num_patches, latest_acquired_patches, program );
      end
    end
    
    %%%%%%%%%%%%%%%%
    % Editing here %
    %%%%%%%%%%%%%%%%
    
    % Generates n bags of trials where n is the number of reps. Then
    % samples from each bag of trials without repeats and deletes that
    % trial from the bag.
    
    function trial_order = generate_trial_order(obj)
      
      % Initial assignments %
      
      obj.generate_trial_order_again    = false;
      obj.trial_set                     = obj.trial_set_generator.generate_trial_set();
      num_trial_types                   = numel(obj.trial_set);
      n_reps                            = obj.trial_reps;
      trial_order                       = nan(n_reps*num_trial_types,1);
      
      % Operations %
      
      % Generate list of all trials
      trial_stack = repmat( (1:num_trial_types)', [1 n_reps] );
      trial_stack = trial_stack(:);
      % Keep sampling from trial_stack until it is empty
      trial_order_idx = 1;
      while ~isempty(trial_stack)
        trial_sample = randsample( trial_stack, 1 );
        % Store the first trial irrespectively
        if trial_order_idx == 1
          trial_order(trial_order_idx) = trial_sample;
          trial_stack( find( trial_stack == trial_sample, 1 ) ) = [];
        % Check for repeats from next trial onwards
        else
          if trial_sample ~= trial_order(trial_order_idx-1)
            trial_order(trial_order_idx) = trial_sample;
            trial_stack( find( trial_stack == trial_sample, 1 ) ) = [];
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
            else
              trial_order(trial_order_idx) = trial_sample;
              trial_stack( find( trial_stack == trial_sample, 1 ) ) = [];
            end
          end
        end
        trial_order_idx = trial_order_idx+1;
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Modify this to draw heterogenous patches for different trials %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function patch_info = generate(obj, patch_targets, program)
      
      latest_acquired_patches = get_latest_acquired_patches( program );
      
      appearance_func = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches = numel( patch_targets );
      
      
      %{
      
      if ( obj.generate_new_trial_set() )
        % Check to see that trial_order_index is <= number of possible
        % trials.
        obj.trial_set = obj.trial_set_generator.generate();
        obj.trial_order = randperm( numel(obj.trial_set) );
        obj.trial_order_index = 1;
      end
      
      if ( obj.move_to_next_trial_set() )
        % Check to see if any patches remain, or if more than 2
        % trials have passed with this set of patches.
        obj.curr_patches = obj.trial_set{obj.trial_order_index};
        patch_info = obj.curr_patches;
      else
        patch_info = get_non_acquired_patches( obj.curr_patches );
        obj.curr_patches = patch_info;
      end
      
      %}
      
      if ( obj.generate_new_patch_info(num_patches, latest_acquired_patches, program) )
        pct.util.log( 'Generating new patch info.', pct.util.LogInfo(logging_id()) );
        
        radius = program.Value.patch_distribution_radius;
        rect = program.Value.window.Rect;
        coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );

        patch_info = pct.util.PatchInfo.empty();
        
        % patch_list = obj.trial_set.sample(); % this is a function within
        % trial_set
        
        % Work here in trying to assign the appearance of various patches.
        % Chesk the functions in Util.
        for i = 1:num_patches
          acquirable_by = {'m1', 'm2'};
          strategy = obj.block_type;

          new_patch_info = pct.util.PatchInfo();
          new_patch_info.AcquirableBy = acquirable_by; % This needs to be changed to patch_list(i).Acq...
          new_patch_info.Strategy = strategy; % This too
          new_patch_info.Position = coordinates(:, i);
          new_patch_info.Target = patch_targets{i};
          new_patch_info.Index = i;
          new_patch_info.ID = obj.next_patch_id;
          new_patch_info.SetID = obj.next_set_id;
          % Configure color, and other appearence properties.
          new_patch_info = appearance_func( new_patch_info );

          patch_info(end+1) = new_patch_info;
          
          obj.next_patch_id = obj.next_patch_id + 1;
        end

        obj.trial_ind = mod( obj.trial_ind + 1, obj.trials_per_block );

        if ( obj.trial_ind == 0 )
          obj.select_next_block_strategy();
        end
        
        obj.last_patch_info = patch_info;
        obj.next_set_id = obj.next_set_id + 1;
        obj.num_trials_persisted_patch_info = 1;
      else
        pct.util.log( 'Reusing patch info.', pct.util.LogInfo(logging_id()) );
        
        if ( obj.persist_patch_info_until_exhausted )
          % Select patches that were not acquired on the last trial.
          last_info = obj.last_patch_info;
          patch_info = filter_non_acquired_patches( last_info, latest_acquired_patches );
          obj.last_patch_info = patch_info;
          
        else
          patch_info = obj.last_patch_info;
        end
        
        obj.num_trials_persisted_patch_info = ...
          obj.num_trials_persisted_patch_info + 1;
      end
    end
  end
 end

function acquired = get_latest_acquired_patches(program)

trial_data = program.Value.data.Value;

if ( isempty(trial_data) )
  acquired = {};
else
  acquired = trial_data(end).just_patches.acquired_patches;
end

end

function remaining_patches = filter_non_acquired_patches(possible_patches, maybe_acquired_patches)

acquired_patches = maybe_acquired_patches(cellfun(@(x) ~isempty(x), maybe_acquired_patches));
acquired_patches = vertcat( pct.util.PatchInfo.empty(), acquired_patches{:} );

possible_ids = [possible_patches.ID];
acquired_ids = [acquired_patches.ID];

was_acquired = ismember( possible_ids, acquired_ids );
remaining_patches = possible_patches(~was_acquired);

end

function id = logging_id()
id = 'BlockedMultiPatchTrials';
end