classdef PatchInfo
  properties (Constant = true)
    Strategies = {'self', 'compete', 'cooperate'};
  end
  
  properties
    AcquirableBy = {};
    AcquiredByName = '';
    AcquiredByIndex = 0;
    Strategy = 'self';
    Agent = '';
    
    Color = zeros( 1, 3 );
    Position = zeros( 1, 3 );
    
    Target = ptb.Null();
    
    Index = 1;
    ID = 1;
    TrialTypeID = 1;
    SequenceID = 1;
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
    
    function obj = set.TrialTypeID(obj, v)
      validateattributes( v, {'double'}, {'scalar', 'integer'} ...
        , mfilename, 'TrialTypeID' );
      obj.TrialTypeID = v;
    end
    
    function obj = set.SequenceID(obj, v)
      validateattributes( v, {'double'}, {'scalar', 'integer'} ...
        , mfilename, 'SequenceID' );
      obj.SequenceID = v;
    end
    
    function obj = set.ID(obj, v)
      validateattributes( v, {'double'}, {'scalar', 'integer'} ...
        , mfilename, 'ID' );
      obj.ID = v;
    end
    
    function obj = set.Index(obj, v)
      validateattributes( v, {'double'}, {'scalar', 'integer'} ...
        , mfilename, 'Index' );
      obj.Index = v;
    end
    
    function obj = set.Agent(obj, v)
      validateattributes( v, {'char'}, {'scalartext'} ...
        , mfilename, 'Agent' );
      obj.Agent = v;
    end
  end
end