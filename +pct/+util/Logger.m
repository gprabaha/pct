classdef Logger < handle
  properties
    include_everything = false;
    exclude_tags = {};
    include_tags = {};
  end
  
  methods
    function obj = Logger()
    end
    
    function set.include_everything(obj, tf)
      validateattributes( tf, {'logical'}, {'scalar'}, mfilename, 'include_everything' );
      obj.include_everything = tf;
    end
    
    function set.exclude_tags(obj, tags)
      validateattributes( tags, {'cell'}, {'2d'}, mfilename, 'tags' );
      if ( ~iscellstr(tags) )
        error( 'Expected tags to be a cell array of strings.' );
      end
      obj.exclude_tags = unique( tags(:)' );
    end
    
    function set.include_tags(obj, tags)
      validateattributes( tags, {'cell'}, {'2d'}, mfilename, 'tags' );
      if ( ~iscellstr(tags) )
        error( 'Expected tags to be a cell array of strings.' );
      end
      obj.include_tags = unique( tags(:)' );
    end
    
    function log(obj, message, info)
      do_log = false;
      
      if ( obj.include_everything )
        do_log = true;
      elseif ( ~ismember(info.tag, obj.exclude_tags) && ...
                ismember(info.tag, obj.include_tags) )
        do_log = true;
      end
      
      if ( do_log )
        fprintf( '%s\n', make_log_string(message, info) );
      end
    end
  end
end

function s = make_log_string(message, info)

if ( ~isempty(info.context) )
  context = sprintf( '[%d] %s (%s)' ...
    , info.context.line, info.context.file, info.tag );
else
  context = sprintf( '(%s)', info.tag );
end

s = sprintf( '%s: %s', context, message );

end