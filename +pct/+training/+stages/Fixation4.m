classdef Fixation4 < pct.training.stages.FixationTrainingStage
  properties
  end
  
  methods
    function obj = Fixation4()
      fix_dur = 0.25;
      fix_hold_dur = 0.1;
      patch_dur = 0.1;
      
      obj@pct.training.stages.FixationTrainingStage( fix_dur, fix_hold_dur, patch_dur );
    end
  end
end