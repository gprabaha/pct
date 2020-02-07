classdef TrainingStageManager < handle
  properties (GetAccess = public, SetAccess = private)
    Stages = {};
    CurrentStageIndex;
    WrapAround = false;
  end
  
  methods
    function obj = TrainingStageManager()
      obj.CurrentStageIndex = 1;
    end
    
    function add_stage(obj, stage)
      validateattributes( stage, {'pct.util.TrainingStage'}, {'scalar'} ...
        , mfilename, 'stage' );
      obj.Stages{end+1} = stage;
    end
    
    function apply(obj, program)
      if ( isempty(obj.Stages) )
        return
      end
      
      update_current_stage_index( obj );
      
      curr_stage = obj.Stages{obj.CurrentStageIndex};
      apply( curr_stage, program );
      
      obj.CurrentStageIndex = obj.CurrentStageIndex + direction( curr_stage, program );
    end
  end
  
  methods (Access = private)
    function update_current_stage_index(obj)
      if ( obj.CurrentStageIndex > numel(obj.Stages) )
        if ( obj.WrapAround )
          obj.CurrentStageIndex = 1;
        else
          obj.CurrentStageIndex = numel( obj.Stages );
        end
      elseif ( obj.CurrentStageIndex < 1 )
        if ( obj.WrapAround )
          obj.CurrentStageIndex = numel( obj.Stages );
        else
          obj.CurrentStageIndex = 1;
        end
      end
    end
  end
end