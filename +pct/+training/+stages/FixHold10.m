classdef FixHold10 < pct.training.stages.FixationTrainingStage
  properties
  end
  
  methods
    function obj = FixHold10()
      fix_dur = 0.3;
      fix_hold_dur = 0.375;
      patch_dur = 0.1;
      
      obj@pct.training.stages.FixationTrainingStage( fix_dur, fix_hold_dur, patch_dur );
      obj.Name = 'FixHold10';
    end
  end
end