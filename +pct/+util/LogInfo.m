classdef LogInfo  
  properties (Constant = true)
    severity_strings = { 'info', 'warning', 'severe' };
  end
  
  properties
    tag;
    severity;
    context = [];
  end
  
  methods
    function obj = LogInfo(tag, severity)
      if ( nargin < 1 )
        tag = '';
      end
      
      if ( nargin < 2 )
        severity = 'info';
      end
      
      obj.tag = tag;
      obj.severity = severity;
      
      s = dbstack;
      if ( numel(s) >= 2 )
        obj.context = s(2);
      end
    end
    
    function obj = set.tag(obj, t)
      validateattributes( t, {'char'}, {'scalartext'}, mfilename, 'tag' );
      obj.tag = t;
    end
    
    function obj = set.severity(obj, s)
      obj.severity = ...
        validatestring( s, obj.severity_strings, mfilename, 'severity' );
    end
  end
end