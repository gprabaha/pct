classdef FixHold3 < pct.training.stages.FixationTrainingStage
  properties
  end
  
  methods
    function obj = FixHold3()
      fix_dur = 0.3;
      fix_hold_dur = 0.25;
      patch_dur = 0.1;
      
      obj@pct.training.stages.FixationTrainingStage( fix_dur, fix_hold_dur, patch_dur );
      obj.Name = 'FixHold3';
    end
  end
end