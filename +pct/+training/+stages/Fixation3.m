classdef Fixation3 < pct.training.stages.FixationTrainingStage
  properties
  end
  
  methods
    function obj = Fixation3()
      fix_dur = 0.2;
      fix_hold_dur = 0.1;
      patch_dur = 0.1;
      
      obj@pct.training.stages.FixationTrainingStage( fix_dur, fix_hold_dur, patch_dur );
      obj.Name = 'Fixation3';
    end
  end
end