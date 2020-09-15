classdef BlockedCompeteCooperate < pct.util.EstablishPatchInfo
  properties
    block_types = {'compete', 'cooperate'};
    block_type = 'compete';
    block_type_ind = 1;
    trials_per_block = 10;
    trial_ind = 0;
    next_block_strategy = 'sequential'; % 'random'
  end
  
  methods
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
    
    function patch_info = generate(obj, patch_targets, program)
      appearance_func = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches = numel( patch_targets );

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
    end
  end
end