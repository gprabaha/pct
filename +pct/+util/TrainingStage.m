classdef TrainingStage < handle
  methods
    function obj = TrainingStage()
    end
    
    function d = direction(obj, program)
      d = 0;
      
      if ( advance(obj, program) )
        d = 1;
        return
      end
      
      if ( revert(obj, program) )
        d = -1;
        return
      end
    end
  end
  
  methods (Access = public, Abstract = true)
    apply(obj, program)
    tf = advance(obj, program)
    tf = revert(obj, program)
    transition(from, to, program)
  end
end