classdef DebugPatchInfo < pct.util.EstablishPatchInfo
  methods
    function patch_info = generate(obj, patch_targets, program)
      patch_color_map = program.Value.stimuli_setup.patch.patch_identity_color_map;
      num_patches = numel( patch_targets );

      radius = program.Value.patch_distribution_radius;
      rect = program.Value.window.Rect;
      coordinates = pct.util.assign_patch_coordinates( num_patches, radius, rect );

      patch_info = pct.util.PatchInfo.empty();

      for i = 1:num_patches
        if ( rand() > 0.5 )
          acquirable_by = 'm1';
        else
          acquirable_by = 'm2';
        end
        
        new_patch_info = pct.util.PatchInfo();
        new_patch_info.AcquirableBy = {acquirable_by};
        new_patch_info.Color = patch_color_map(acquirable_by);
        new_patch_info.Strategy = 'self';
        new_patch_info.Position = coordinates(:, i);
        new_patch_info.Target = patch_targets{i};

        patch_info(end+1) = new_patch_info;
      end
    end
  end
end