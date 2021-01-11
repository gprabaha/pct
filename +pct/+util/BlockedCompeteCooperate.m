classdef BlockedCompeteCooperate < pct.util.EstablishPatchInfo
  properties
    block_types = {'compete', 'cooperate'};
    block_type = 'cooperate'; %'compete';
    block_type_ind = 1;
    trials_per_block = 10;
    trial_ind = 0;
    next_block_strategy = 'sequential'; % 'random'
    last_patch_info = pct.util.PatchInfo.empty();
    persist_patch_info_until_exhausted = false;
    max_num_trials_persist_patch_info = 2;
    num_trials_persisted_patch_info = 0;    
    next_set_id = 1;
    next_patch_id = 1;
  end
  
  methods
    function obj = BlockedCompeteCooperate(varargin)
      defaults = struct();
      defaults.trials_per_block = 10;
      defaults.next_block_strategy = 'sequential';
      defaults.block_types = { 'compete', 'cooperate' };
      defaults.start_block_type = 'cooperate';
      defaults.persist_patch_info_until_exhausted = false;
      defaults.max_num_trials_persist_patch_info = 2;
      params = shared_utils.general.parsestruct( defaults, varargin );
      
      obj.trials_per_block = params.trials_per_block;
      obj.block_types = params.block_types;
      obj.block_type = params.start_block_type;
      obj.next_block_strategy = params.next_block_strategy;
      obj.persist_patch_info_until_exhausted = params.persist_patch_info_until_exhausted;
      obj.max_num_trials_persist_patch_info = params.max_num_trials_persist_patch_info;
      
      [~, block_ind] = ismember( obj.block_type, obj.block_types );
      if ( block_ind == 0 )
        error( 'Unrecognized block type "%s".', obj.block_type );
      end
      
      obj.block_type_ind = block_ind;
    end
    
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
    
    function patch_info = generate(obj, patch_targets, program)
      latest_acquired_patches = get_latest_acquired_patches( program );
      
      appearance_func = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches = numel( patch_targets );
      
      if ( obj.generate_new_patch_info(num_patches, latest_acquired_patches, program) )
        pct.util.log( 'Generating new patch info.', pct.util.LogInfo(logging_id()) );
        
        radius = program.Value.patch_distribution_radius;
        rect = program.Value.window.Rect;
        coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );

        patch_info = pct.util.PatchInfo.empty();

        for i = 1:num_patches                
          acquirable_by = {'m1', 'm2'};
          strategy = obj.block_type;

          new_patch_info = pct.util.PatchInfo();
          new_patch_info.AcquirableBy = acquirable_by;
          new_patch_info.Strategy = strategy;
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
id = 'BlockedCompeteCooperate';
end