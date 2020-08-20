classdef PatchInfo
  properties (Constant = true)
    Strategies = {'self', 'compete', 'cooperate'};
  end
  
  properties
    AcquirableBy = {};
    Strategy = 'self';
    
    Color = zeros( 1, 3 );
    Position = zeros( 1, 3 );
    
    Target = ptb.Null();
  end
  
  methods
    function obj = set.AcquirableBy(obj, to)
      validateattributes( to, {'cell'}, {}, mfilename, 'AcquirableBy' );
      to = cellstr( to );
      for i = 1:numel(to)
        to{i} = validatestring( to{i}, {'m1', 'm2'}, mfilename, 'AcquirableBy' );
      end
      obj.AcquirableBy = to;
    end
    
    function obj = set.Strategy(obj, v)
      obj.Strategy = validatestring( v, obj.Strategies, mfilename, 'strategy' );
    end
    
    function tf = acquireable_by_m2(obj)
      % True if m2 can, potentially, acquire this patch.
      tf = ismember( 'm2', obj.AcquirableBy );
    end
  end
end