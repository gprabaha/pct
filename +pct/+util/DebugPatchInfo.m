classdef DebugPatchInfo < pct.util.EstablishPatchInfo
  methods
    function patch_info = generate(obj, patch_targets, program)
      appearance_func = program.Value.stimuli_setup.patch.patch_appearance_func;
      num_patches = numel( patch_targets );

      radius = program.Value.patch_distribution_radius;
      rect = program.Value.window.Rect;
      coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );

      patch_info = pct.util.PatchInfo.empty();

      for i = 1:num_patches        
        strat_condition = rand();
        
        % Pick a strategy at random.
        if ( strat_condition < 0.5 )
          strategy = 'self';
        elseif ( strat_condition < 0.75 )
          strategy = 'compete';
        else
%           strategy = 'cooperate';
          strategy = 'compete';
        end
        
        % For the self strategy, determine whether the patch is an m1 or m2
        % collectable patch, at random. For other strategies, the patch is 
        % collectable by either subject.
        if ( strcmp(strategy, 'self') )
          if ( rand() > 0.5 )
            acquirable_by = {'m1'};
          else
            acquirable_by = {'m1'};
%             acquirable_by = {'m2'};
          end
        else
          acquirable_by = {'m1', 'm2'};
        end
        
        new_patch_info = pct.util.PatchInfo();
        new_patch_info.AcquirableBy = acquirable_by;
        new_patch_info.Strategy = strategy;
        new_patch_info.Position = coordinates(:, i);
        new_patch_info.Target = patch_targets{i};
        % Configure color, and other appearence properties.
        new_patch_info = appearance_func( new_patch_info );

        patch_info(end+1) = new_patch_info;
      end
    end
  end
end