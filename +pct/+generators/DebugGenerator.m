classdef DebugGenerator < handle
  properties (Access = private)
    source;
    frame_timer;
    origin = [0; 0];
    destination = [0; 0];
    total_time = 1;
    noise = 1.5;
    use_subject_rt_based_saccade_time = false;
    cursor_override_increment = 0.1;  % seconds;
    cursor_override_amount = 0;
    current_saccade_time = 0;
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
      obj.destination = start_pos_val+1;
      obj.total_time = 1;
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      obj.source.SettableX = rect_size(1)/2;
      obj.source.SettableY = rect_size(2)/2;
      obj.source.SettableIsValidSample = true;
      reset( obj.frame_timer );
    end
    
    function time = get_current_saccade_time(obj)
      time = obj.current_saccade_time;
    end
    
    function time = establish_saccade_time(obj, program)
      data = program.Value.data.Value;
      training_data = program.Value.training_data;
      
      all_m1_rts = [];
      
      for i = 1:numel(data)
        patch_entry_times = data(i).just_patches.patch_entry_times;
        state_start_time = data(i).just_patches.entry_time;
        
        if ( ~isnan(state_start_time) )
          % Get the patch entry times for m1, separately for each patch.
          % Get the maximum (?) entry time, and subtract it from the state
          % entry time to get a reaction time / saccade time for m1.
          m1_entry_times = patch_entry_times(1, :);
          
          rts = nan( numel(m1_entry_times), 1 );
          for j = 1:numel(rts)
            if ( ~isempty(m1_entry_times{j}) )
              % Should this be max?
              rts(j) = max( m1_entry_times{j} ) - state_start_time;
            end
          end
          
          all_m1_rts = [ all_m1_rts; rts(~isnan(rts)) ];
        end
      end
      
      if ( training_data.mean_m2_saccade_velocity_shift_direction ~= 0 )
        % Right or left key was pressed, increase / decrease the mean
        % saccade velocity.
        dir = training_data.mean_m2_saccade_velocity_shift_direction;        
        obj.cursor_override_amount = ...
          obj.cursor_override_amount + obj.cursor_override_increment * dir;
        
        fprintf( '\n Applying override: %0.2f', obj.cursor_override_amount );
      end
      
      override_amt = obj.cursor_override_amount;
      
      if ( ~isempty(all_m1_rts) && obj.use_subject_rt_based_saccade_time )
        time = mean( all_m1_rts ) + override_amt;
      else
        time = program.Value.generator_m2_saccade_time + override_amt;
      end
      
      obj.current_saccade_time = time;
    end
    
    function initialize(obj, patch_info, program)
%       [start_pos_val, end_pos_val, total_time_val] = m2_saccade_attributes( obj, program );
      [start_pos_val, end_pos_val] = m2_saccade( patch_info, program );      
      obj.origin = start_pos_val;
      obj.destination = end_pos_val;
      obj.total_time = establish_saccade_time( obj, program );
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
      noise = obj.noise;
      
      current_t = elapsed( obj.frame_timer );
      
      [X_pos, Y_pos] = pct.generators.update_X_Y_pos_gaussian_velocity(...
        current_t, origin_val, destination_val, total_time_val);
      
      assert(~isnan( X_pos));
      
      obj.source.SettableX = X_pos + normrnd( 0, noise );
      obj.source.SettableY = Y_pos + normrnd( 0, noise );
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

function [start_pos, end_pos] = m2_saccade(patch_info, program)

rect = program.Value.window.Rect;
rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      
start_pos = [0.5 * rect_size(1), 0.5 * rect_size(2)];
end_pos = start_pos;

% This is where the total saccade time gets assigned
total_time = program.Value.generator_m2_saccade_time;

maybe_m2_patches = pct.util.PatchInfo.empty();

for i = 1:numel(patch_info)
  if ( acquireable_by_m2(patch_info(i)) )
    maybe_m2_patches(end+1) = patch_info(i);
  end
end

if ( isempty(maybe_m2_patches) )
  % No patches acquireable by m2.
  return
end

patch_ind = randi( numel(maybe_m2_patches), 1 );
end_pos = maybe_m2_patches(patch_ind).Position(:)' .* rect_size(:)';
% end_pos = maybe_m2_patches(patch_ind).Position(:)';

end