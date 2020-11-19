classdef DebugGeneratorManyPatch < handle
  properties (Access = private)
    source;
    frame_timer;
    saccades = {};
    origin = [0; 0];
    destination = [0; 0];
    total_time = 1;
    noise = 1;
    use_subject_rt_based_saccade_time = false;
    cursor_override_increment = 0.05;  % seconds;
    cursor_override_amount = 0;
    current_saccade_time = 0;
    current_saccade_index;
  end
  methods
    function obj = DebugGeneratorManyPatch(source)
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
          
          % This command gets the m1 patch entry times for all patches
          m1_entry_times = patch_entry_times(1, :);
          
          rts = nan( numel(m1_entry_times), 1 );
          for j = 1:numel(rts)
            if ( ~isempty(m1_entry_times{j}) )
              % I made this min to capture the first entry
              rts(j) = min( m1_entry_times{j} ) - state_start_time;
            end
          end
          
          all_m1_rts = [ all_m1_rts; rts(~isnan(rts)) ];
        end
      end
      
      if ( ~isempty(all_m1_rts) )
        time = mean( all_m1_rts ); % can initiate a norand generator here
      end
      
      if ( isfield(training_data, 'mean_m2_saccade_velocity_shift_direction') && ...
          training_data.mean_m2_saccade_velocity_shift_direction ~= 0 )
        program.Value.training_data.mean_m2_saccade_velocity_shift_direction = 0;
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
        % Made the shift speed based instead of time
        average_speed = program.Value.generator_m2_saccade_speed;
        average_speed = average_speed + override_amt;
        time = 1/average_speed;
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
      obj.current_saccade_index = 1;
      reset( obj.frame_timer );
    end
    
    function update(obj, program)
      saccade_list = generate_saccade_list(obj, patch_info, program);
      current_t = elapsed( obj.frame_timer );
      saccade_index = obj.current_saccade_index;
      origin_val = saccade_list{saccade_index}.origin;
      destination_val = saccade_list{saccade_index}.destination;
      total_time_val = saccade_list{saccade_index}.total_time;
      average_velocity = 1/total_time_val;
      noise = obj.noise;
      [X_pos, Y_pos] = pct.generators.update_X_Y_pos_gaussian_velocity(...
        current_t, origin_val, destination_val, average_velocity);
      assert(~isnan( X_pos));
      obj.source.SettableX = X_pos + normrnd( 0, noise );
      obj.source.SettableY = Y_pos + normrnd( 0, noise );
      next_saccade_index = obj.current_saccade_index + 1;
      % This resets timer for the next saccade once one saccade is done
      if current_t > total_time_val && next_saccade_index <= numel(saccade_list)
        reset( obj.frame_timer );
        obj.current_saccade_index = next_saccade_index;
      end
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
    
    function [start_pos_vals, end_pos_vals, total_time_val] = m2_saccade_attributes( obj, program )
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
      
      start_pos_vals = central_position;
      end_pos_vals = absolute_target_position;
      average_speed = program.Value.generator_m2_saccade_speed;
      total_time_val = 1/average_speed;
    end
  end
end

function saccade_struct = make_saccade(origin, destination, current_time, total_time)

saccade_struct = struct(...
  'origin',           origin,...
  'destination',      destination, ...
  'current_time',     current_time, ...
  'total_time',       total_time ...
  );

end

function saccade_list = generate_saccade_list(obj, patch_info, program)

rect = program.Value.window.Rect;
rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];

% This one currently uses the constant time assigned in conf
average_speed = program.Value.generator_m2_saccade_speed;
total_time = 1/average_speed;
wait_time = program.Value.generator_m2_wait_time;

start_pos = [0.5 * rect_size(1), 0.5 * rect_size(2)];

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

current_patch_ind = nan;
for patch_ind = 1:numel(maybe_m2_patches)
  % If this is the first saccade, set origin to fixation
  if patch_ind == 1
    origin = start_pos;
  % Else make the current patch the origin
  else
    origin = maybe_m2_patches(current_patch_ind).Position(:)' .* rect_size(:)';
  end
  % If this is the first saccade, chose destination randomly from available
  % patches
  if isnan(current_patch_ind)
    target_patch_ind = randi( numel(maybe_m2_patches), 1 );
  % Else select randomly from remaining patches
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % We have to account for the fact that some of the remaining patches
  % could already have been collected by M1 and thus have to be removed
  % from the available pool
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  else
    available_patches = 1:numel(maybe_m2_patches);
    available_patches(available_patches==current_patch_ind) = [];
    target_patch_ind = randsample( available_patches, 1 );
  end
  destination = maybe_m2_patches(target_patch_ind).Position(:)' .* rect_size(:)';
  saccade_interval_struct = make_saccade(origin, origin, nan, wait_time);
  temp_saccade_struct = make_saccade(origin, destination, nan, total_time);
  if patch_ind > 1
    obj.saccades{end+1} = saccade_interval_struct;
    obj.saccades{end+1} = temp_saccade_struct;
  else
    obj.saccades{end+1} = temp_saccade_struct;
  end
  current_patch_ind = target_patch_ind;
end

end


% function [start_pos, end_pos] = m2_saccade(patch_info, program)
% 
% rect = program.Value.window.Rect;
% rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
%       
% start_pos = [0.5 * rect_size(1), 0.5 * rect_size(2)];
% end_pos = start_pos;
% 
% % This is where the total saccade time gets assigned
% total_time = program.Value.generator_m2_saccade_time;
% 
% maybe_m2_patches = pct.util.PatchInfo.empty();
% 
% for i = 1:numel(patch_info)
%   if ( acquireable_by_m2(patch_info(i)) )
%     maybe_m2_patches(end+1) = patch_info(i);
%   end
% end
% 
% if ( isempty(maybe_m2_patches) )
%   % No patches acquireable by m2.
%   return
% end
% 
% patch_ind = randi( numel(maybe_m2_patches), 1 );
% end_pos = maybe_m2_patches(patch_ind).Position(:)' .* rect_size(:)';
% % end_pos = maybe_m2_patches(patch_ind).Position(:)';
% 
% end