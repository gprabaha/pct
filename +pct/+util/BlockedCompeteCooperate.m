classdef BlockedCompeteCooperate < pct.util.EstablishPatchInfo
  properties
    block_types = {'compete', 'cooperate'};
    block_type = 'cooperate'; %'compete';
    block_type_ind = 1;
    trials_per_block = 10;
    trial_ind = 0;
    next_block_strategy = 'sequential'; % 'random'
    last_patch_info = pct.util.PatchInfo.empty();
  end
  
  methods
    function obj = BlockedCompeteCooperate(varargin)
      defaults = struct();
      defaults.trials_per_block = 10;
      defaults.next_block_strategy = 'sequential';
      defaults.block_types = { 'compete', 'cooperate' };
      defaults.start_block_type = 'cooperate';
      params = shared_utils.general.parsestruct( defaults, varargin );
      
      obj.trials_per_block = params.trials_per_block;
      obj.block_types = params.block_types;
      obj.block_type = params.start_block_type;
      obj.next_block_strategy = params.next_block_strategy;
      
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
    
    function tf = update_patch_info(obj, num_patches, program)
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
    
    function patch_info = generate(obj, patch_targets, program)
      appearance_func = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches = numel( patch_targets );
      
      if ( obj.update_patch_info(num_patches, program) )
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
          % Configure color, and other appearence properties.
          new_patch_info = appearance_func( new_patch_info );

          patch_info(end+1) = new_patch_info;
        end

        obj.trial_ind = mod( obj.trial_ind + 1, obj.trials_per_block );

        if ( obj.trial_ind == 0 )
          obj.select_next_block_strategy();
        end
        
        obj.last_patch_info = patch_info;
      else
        patch_info = obj.last_patch_info;
      end
    end
  end
end