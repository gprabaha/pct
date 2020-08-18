classdef EstablishPatchInfo < handle
  methods (Abstract = true)
    [info] = generate(obj, patch_targets, program)
  end
end