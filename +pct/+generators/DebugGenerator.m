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
    
    function update(obj, program)
   
      delta_t = elapsed( obj.frame_timer );
      
      [X_increment, Y_increment] = update_X_Y_pos( obj, delta_t, program );
      obj.source.SettableX = obj.source.SettableX + X_increment;
      obj.source.SettableY = obj.source.SettableY + Y_increment;
      reset( obj.frame_timer );
    end
    
    function set.source(obj, to)
      validateattributes( to, {'ptb.sources.Generator'} ...
        , {'scalar'}, mfilename, 'source' );
      obj.source = to;
    end
    
    function [X_increment, Y_increment] = update_X_Y_pos( obj, delta_t, program )
      saccade_attributes = program.Value.m2_saccade_attributes.Value;
      start_pos = saccade_attributes.start_pos;
      end_pos = saccade_attributes.end_pos;
      total_time = saccade_attributes.total_time;
      
      total_X = end_pos(1) - start_pos(1);
      total_Y = end_pos(2) - start_pos(2);
      
      time_frac = delta_t/total_time;
      X_increment = total_X * time_frac;
      Y_increment = total_Y * time_frac;
    end
  end
end