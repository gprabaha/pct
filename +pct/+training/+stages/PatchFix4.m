classdef PatchFix4 < pct.training.stages.FixationTrainingStage
  properties
  end
  
  methods
    function obj = PatchFix4()
      fix_dur = 0.3;
      fix_hold_dur = 0.5;
      patch_dur = 0.3;
      
      obj@pct.training.stages.FixationTrainingStage( fix_dur, fix_hold_dur, patch_dur );
      obj.Name = 'PatchFix4';
    end
  end
end