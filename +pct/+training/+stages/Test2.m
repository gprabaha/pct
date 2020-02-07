classdef Test2 < pct.util.TrainingStage
  properties
  end
  
  methods
    function obj = Test2()
      obj@pct.util.TrainingStage();
    end
  end
  
  methods (Access = public)
    function apply(obj, program)
      program.Value.stimuli.fix_square.FaceColor = [0, 255, 0];
    end
    
    function tf = advance(obj, program)
      tf = true;
    end
    
    function tf = revert(obj, program)
      tf = false;
    end
  end
end