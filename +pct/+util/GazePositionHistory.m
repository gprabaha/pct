classdef GazePositionHistory < handle
  properties (Access = public)
    Sampler = [];
  end
  
  properties (SetAccess = private, GetAccess = public)
    MinimumInterSampleInterval = 1e-3;
    HistorySizeSeconds = 250e-3;
  end
  
  properties (Access = private)
    timer_id;
    last_update_time;
    history;
    history_index = 1;
    history_size_samples;
  end
  
  methods
    function obj = GazePositionHistory(sampler, min_isi, history_size_s)
      obj.Sampler = sampler;
      obj.timer_id = tic();
      obj.last_update_time = toc( obj.timer_id );
      
      if ( nargin > 1 )
        obj.MinimumInterSampleInterval = min_isi;
      end
      
      if ( nargin > 2 )
        obj.HistorySizeSeconds = history_size_s;
      end
      
      history_size_samples = max( 1, ...
        floor(obj.HistorySizeSeconds / obj.MinimumInterSampleInterval) );
      
      obj.history = nan( history_size_samples, 3 ); % x, y, dt
      obj.history_size_samples = history_size_samples;
    end
    
    function set.Sampler(obj, sampler)
      validateattributes( sampler, {'ptb.XYSampler'}, {'scalar'} ...
        , mfilename, 'sampler' );
      obj.Sampler = sampler;
    end
    
    function hist = get_history(obj)
      hist = obj.history;
    end
    
    function update(obj)
      curr_t = toc( obj.timer_id );
      dt = curr_t - obj.last_update_time;
      
      if ( dt < obj.MinimumInterSampleInterval )
        return
      end
      
      obj.last_update_time = curr_t;
      
      x = obj.Sampler.X;
      y = obj.Sampler.Y;
      
      hist_ind = obj.history_index;
      
      if ( hist_ind <= obj.history_size_samples )
        obj.history(hist_ind, 1) = x;
        obj.history(hist_ind, 2) = y;
        obj.history(hist_ind, 3) = dt;
        obj.history_index = hist_ind + 1;
      else
        obj.history(1:end-1, :) = obj.history(2:end, :);
        obj.history(end, 1) = x;
        obj.history(end, 2) = y;
        obj.history(end, 3) = dt;
      end
    end
  end
end