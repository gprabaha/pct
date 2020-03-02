classdef DebugGenerator < handle
  properties (Access = private)
    source;
    frame_timer;
  end
  methods
    function obj = DebugGenerator(source)
      obj.source = source;
      obj.frame_timer = ptb.Clock();
      
      source.SettableX = 0;
      source.SettableY = 0;
      source.SettableIsValidSample = true;
    end
    
    function initialize(obj, program)
%       saccade_target = choose_target( target_locations );
%       time_to_target = calculate_saccade_end_time();
%       
%       initial_position = calculate_initial_gaze_position();
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      obj.source.SettableX = rect_size(1)/2;
      obj.source.SettableY = rect_size(2)/2;
      obj.source.SettableIsValidSample = true;
    end
    
    function update(obj)
   
      delta_t = elapsed( obj.frame_timer );
      
      obj.source.SettableX = obj.source.SettableX + 5 * delta_t;
      reset( obj.frame_timer );
    end
    
    function set.source(obj, to)
      validateattributes( to, {'ptb.sources.Generator'} ...
        , {'scalar'}, mfilename, 'source' );
      obj.source = to;
    end
  end
end