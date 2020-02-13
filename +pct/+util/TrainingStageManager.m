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
      
      curr_stage = current_stage( obj );
      direc = direction( curr_stage, program );
      
      if ( direc ~= 0 )
        new_index = maybe_wrap_index( obj, obj.CurrentStageIndex + direc );
        new_stage = obj.Stages{new_index};
        transition( curr_stage, new_stage, direc, program );
      else
        new_index = obj.CurrentStageIndex;
      end
      
      obj.CurrentStageIndex = new_index;
      curr_stage = current_stage( obj );
      apply( curr_stage, program );
    end
    
    function transition(from, to, direc, program)
      %
    end
  end
  
  methods (Access = private)
    function stage = current_stage(obj)
      if ( obj.CurrentStageIndex > numel(obj.Stages) )
        stage = [];
      else
        stage = obj.Stages{obj.CurrentStageIndex};
      end
    end
    
    function index = maybe_wrap_index(obj, index)      
      if ( index > numel(obj.Stages) )
        if ( obj.WrapAround )
          index = 1;
        else
          index = numel( obj.Stages );
        end
      elseif ( index < 1 )
        if ( obj.WrapAround )
          index = numel( obj.Stages );
        else
          index = 1;
        end
      end
    end
  end
end