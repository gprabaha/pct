classdef OnlineSaccadeVelocityEstimator < handle
  properties (Access = public)
    PositionHistory;
    Smooth = true;
    SmoothingSigma = 4;
  end
  
  properties (SetAccess = private, GetAccess = public)
    VelocityHistorySize = 1;
  end
  
  properties (Access = private)
    velocity_history;
    velocity_history_index = 0;
  end
  
  methods
    function obj = OnlineSaccadeVelocityEstimator(history, history_size)      
      obj.PositionHistory = history;
      
      if ( nargin > 1 )
        obj.VelocityHistorySize = history_size;
      end
      
      obj.velocity_history = zeros( obj.VelocityHistorySize, 2 );
    end
    
    function set.PositionHistory(obj, history)
      validateattributes( history, {'pct.util.GazePositionHistory'}, {'scalar'} ...
        , mfilename, 'PositionHistory' );
      obj.PositionHistory = history;
    end
    
    function set.Smooth(obj, v)
      validateattributes( v, {'logical'}, {'scalar'}, mfilename, 'Smooth' );
      obj.Smooth = v;
    end
    
    function mu = get_mean_velocity(obj)
      mu = nanmean( obj.velocity_history, 1 );
    end
    
    function m = get_median_velocity(obj)
      m = nanmedian( obj.velocity_history, 1 );
    end
    
    function register_saccade_end(obj)
      pos_history = get_history( obj.PositionHistory );
      dx = diff( pos_history(:, 1:2), 1, 1 );
      dt = pos_history(2:end, 3);
      
      if ( all(isnan(dt)) )
        return
      end
      
      if ( obj.Smooth )        
        dx(:, 1) = imgaussfilt( dx(:, 1), obj.SmoothingSigma );
        dx(:, 2) = imgaussfilt( dx(:, 2), obj.SmoothingSigma );
        dt = imgaussfilt( dt, obj.SmoothingSigma );
      end
      
      v = dx ./ dt;
      
      write_ind = obj.velocity_history_index + 1;
      obj.velocity_history(write_ind, :) = nanmean( v, 1 );
      
      obj.velocity_history_index = ...
        mod( obj.velocity_history_index + 1, obj.VelocityHistorySize );      
    end
  end
end