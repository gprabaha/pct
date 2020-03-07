classdef DebugGenerator < handle
  properties (Access = private)
    source;
    frame_timer;
    origin = [0; 0];
    destination = [0; 0];
    total_time = 1;
    
  end
  methods
    function obj = DebugGenerator(source)
      obj.source = source;
      obj.frame_timer = ptb.Clock();
      
      source.SettableX = 0;
      source.SettableY = 0;
      source.SettableIsValidSample = true;
    end
    
    function initialize_fixation(obj, program)
      [start_pos_val, end_pos_val, total_time_val] = m2_saccade_attributes( obj, program );
      obj.origin = start_pos_val;
      obj.destination = start_pos_val;
      obj.total_time = 0;
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      obj.source.SettableX = rect_size(1)/2;
      obj.source.SettableY = rect_size(2)/2;
      obj.source.SettableIsValidSample = true;
      reset( obj.frame_timer );
    end
    
    function initialize(obj, program)
      [start_pos_val, end_pos_val, total_time_val] = m2_saccade_attributes( obj, program );
      obj.origin = start_pos_val;
      obj.destination = end_pos_val;
      obj.total_time = total_time_val;
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      obj.source.SettableX = rect_size(1)/2;
      obj.source.SettableY = rect_size(2)/2;
      obj.source.SettableIsValidSample = true;
      reset( obj.frame_timer );
    end
    
    function update(obj, program)
      
      origin_val = obj.origin;
      destination_val = obj.destination;
      total_time_val = obj.total_time;
      
      total_dist = norm( destination_val - origin_val );
      
      current_t = elapsed( obj.frame_timer );
      
      [X_pos, Y_pos] = pct.generators.update_X_Y_pos_gaussian_velocity(...
        current_t, origin_val, destination_val, total_time_val);
      
      deviation = total_dist/75;
      
      obj.source.SettableX = X_pos + normrnd( 0, deviation );
      obj.source.SettableY = Y_pos + normrnd( 0, deviation );
    end
    
    function set.source(obj, to)
      validateattributes( to, {'ptb.sources.Generator'} ...
        , {'scalar'}, mfilename, 'source' );
      obj.source = to;
    end
    
%     function [X_increment, Y_increment] = update_X_Y_pos_uniformly( obj, delta_t, program )
%       saccade_attributes = program.Value.m2_saccade_attributes.Value;
%       start_pos = saccade_attributes.start_pos;
%       end_pos = saccade_attributes.end_pos;
%       total_time = saccade_attributes.total_time;
%       
%       total_X = end_pos(1) - start_pos(1);
%       total_Y = end_pos(2) - start_pos(2);
%       
%       time_frac = delta_t/total_time;
%       X_increment = total_X * time_frac;
%       Y_increment = total_Y * time_frac;
%     end
    
    function [start_pos_val, end_pos_val, total_time_val] = m2_saccade_attributes( obj, program )
      stimuli = program.Value.stimuli;
      stim_name = pct.util.nth_patch_stimulus_name( 1 );
      stimulus = stimuli.(stim_name);
      
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      
      relative_target_position = stimulus.Position.Value;
      absolute_target_position = [relative_target_position(1) * rect_size(1), ...
        relative_target_position(2) * rect_size(2)];
      central_position = [0.5 * rect_size(1), ...
        0.5 * rect_size(2)];
      
      start_pos_val = central_position;
      end_pos_val = absolute_target_position;
      total_time_val = program.Value.generator_m2_saccade_time;
    end
  end
end