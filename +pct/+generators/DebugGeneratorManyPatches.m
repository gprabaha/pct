classdef DebugGeneratorManyPatches < handle
  properties (Access = private)
    source;
    frame_timer;
    saccades = {};
    origin = [0; 0];
    destination = [0; 0];
    noise = 1;
    use_subject_rt_based_saccade_time = false;
    visited_patch_list = [];
    cursor_override_increment = 0.05;  % seconds;
    cursor_override_amount = 0;
    current_saccade_time = 0;
    current_saccade = [];
    
    current_x = 0;
    current_y = 0;
  end
  methods
    function obj = DebugGeneratorManyPatches(source)
      obj.source = source;
      obj.frame_timer = ptb.Clock();
      
      source.SettableX = 0;
      source.SettableY = 0;
      source.SettableIsValidSample = true;
    end
    
    function initialize_fixation(obj, program)
      rect = program.Value.window.Rect;
      rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];
      obj.visited_patch_list = [];
      obj.source.SettableX = rect_size(1)/2;
      obj.source.SettableY = rect_size(2)/2;
      obj.source.SettableIsValidSample = true;
      reset( obj.frame_timer );
      
      total_time = program.Value.config.TIMINGS.time_in.fixation;
      
      obj.saccades = generate_fixation_saccade_list( rect_size, total_time );
    end
    
    function initialize_saccades(obj, patch_info, program, is_patch_acquired)
      reset( obj.frame_timer );
      
%       m2_acquireable_patch_info = ...
%         get_m2_acquireable_patch_info( patch_info, is_patch_acquired );
%       
%       obj.saccades = generate_saccade_list( m2_acquireable_patch_info, program );
      obj.saccades = {};
    end
    
    function time = get_current_saccade_time(obj)
      time = obj.current_saccade_time;
    end
    
    function patch_update(obj, program, patch_info, is_patch_acquired)
      
      prevent_next_patch_repeat = ...
        program.Value.structure.prevent_next_patch_repeat;
      
      if ( isempty(obj.saccades) )
        m2_acquireable_patch_info = ...
          get_m2_acquireable_patch_info( patch_info, is_patch_acquired );
        
        if ( isempty(m2_acquireable_patch_info) )
          return;
        end
        
        % Prevents present patch to be target patch
        if prevent_next_patch_repeat
          if ~isempty(obj.visited_patch_list)
            last_patch = obj.visited_patch_list(end); % check the last target patch
            if numel(m2_acquireable_patch_info) > 1 % check if this is the only patch
              for patch_ind = 1:numel(m2_acquireable_patch_info)
                if m2_acquireable_patch_info(patch_ind).ID == last_patch.ID
                  m2_acquireable_patch_info(patch_ind) = [];
                  break;
                end
              end
            end
          end
        end
        
        m2_patch_ind = randi(numel(m2_acquireable_patch_info), 1);
        m2_target_patch = m2_acquireable_patch_info(m2_patch_ind);
        obj.visited_patch_list = [obj.visited_patch_list m2_target_patch];
        ori = [obj.current_x, obj.current_y];
        
        obj.saccades = generate_saccade_to_patch( ori, m2_target_patch, program );
        reset( obj.frame_timer );
      end
    end
    
    function update(obj, program)
      saccade_list = obj.saccades;
      
      if ( isempty(obj.saccades) )
        return;
      end
      
      current_t = elapsed( obj.frame_timer );
      
      saccade_index = 1;
      origin_val = saccade_list{saccade_index}.origin;
      destination_val = saccade_list{saccade_index}.destination;
      total_time_val = saccade_list{saccade_index}.total_time;
      average_velocity = 1/total_time_val;
      
      [X_pos, Y_pos] = pct.generators.update_X_Y_pos_gaussian_velocity(...
        current_t, origin_val, destination_val, average_velocity);
      assert(~isnan( X_pos));
      
      curr_x = X_pos + normrnd( 0, obj.noise );
      curr_y = Y_pos + normrnd( 0, obj.noise );
      
      obj.current_x = curr_x;
      obj.current_y = curr_y;
      
      obj.source.SettableX = curr_x;
      obj.source.SettableY = curr_y;
      
      % This resets timer for the next saccade once one saccade is done
      if current_t > total_time_val
        obj.saccades(1) = [];
        reset( obj.frame_timer );
      end
    end
    
    function set.source(obj, to)
      validateattributes( to, {'ptb.sources.Generator'} ...
        , {'scalar'}, mfilename, 'source' );
      obj.source = to;
    end
    
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

function fix_list = generate_fixation_saccade_list(rect_size, total_time)

origin = rect_size * 0.5;
destination = origin;

fix_list = {...
  make_saccade( origin, destination, nan, total_time ) ...
};

end

function maybe_m2_patches = get_m2_acquireable_patch_info(patch_info, is_patch_acquired)

maybe_m2_patches = pct.util.PatchInfo.empty();
non_acquired_patch_info = patch_info(~is_patch_acquired);

for i = 1:numel(non_acquired_patch_info)
  if ( acquireable_by_m2(non_acquired_patch_info(i)) )
    maybe_m2_patches(end+1) = non_acquired_patch_info(i);
  end
end

end

function saccades = generate_saccade_to_patch(origin, patch, program)

saccades = {};

average_speed = program.Value.generator_m2_saccade_speed;
total_time = 1/average_speed;
wait_time = program.Value.generator_m2_wait_time;

rect = program.Value.window.Rect;
rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];

destination = patch.Position(:)' .* rect_size(:)';

saccades{end+1} = make_saccade( origin, destination, nan, total_time );
saccades{end+1} = make_saccade( destination, destination, nan, wait_time );

end

function saccade_list = generate_saccade_list(maybe_m2_patches, program)

saccade_list = {};

rect = program.Value.window.Rect;
rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];

% This one currently uses the constant time assigned in conf
average_speed = program.Value.generator_m2_saccade_speed;
total_time = 1/average_speed;
wait_time = program.Value.generator_m2_wait_time;

start_pos = [0.5 * rect_size(1), 0.5 * rect_size(2)];

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
  else
    available_patches = 1:numel(maybe_m2_patches);
    available_patches(available_patches==current_patch_ind) = [];
    target_patch_ind = randsample( available_patches, 1 );
  end
  destination = maybe_m2_patches(target_patch_ind).Position(:)' .* rect_size(:)';
  saccade_interval_struct = make_saccade(origin, origin, nan, wait_time);
  temp_saccade_struct = make_saccade(origin, destination, nan, total_time);
  if patch_ind > 1
    saccade_list{end+1} = saccade_interval_struct;
    saccade_list{end+1} = temp_saccade_struct;
  else
    saccade_list{end+1} = temp_saccade_struct;
  end
  current_patch_ind = target_patch_ind;
end

end