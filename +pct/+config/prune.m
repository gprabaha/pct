function a = prune(a, b)

%   PRUNE -- Remove extraneous fields.
%
%     pct.config.prune( conf ) removes fields of `conf` that are not
%     present in the config file that would be created in a call to
%     `pct.config.create()`. For nested structs, only the nested extraneous
%     fields are removed.
%
%     pct.config.prune(), with no inputs, or pct.config.prune([]), uses the
%     saved config file.
%
%     pct.config.prune( ..., compare_with ); removes fields of `conf` not
%     present in `compare_with`.
%
%     See also pct.config.reconcile

if ( nargin < 1 || isempty(a) )
  a = pct.config.load();
end

if ( nargin < 2 || isempty(b) )
  b = pct.config.create( false ); % don't save
end

extraneous = pct.config.diff( b, false, a );

for i = 1:numel(extraneous)
  split = strsplit( extraneous{i}, '.' );
  
  sub_struct = strjoin( split(1:end-1), '.' );
  field_name = split{end};
  
  cmd = sprintf( 'a%s = rmfield(a%s, ''%s'');' ...
    , sub_struct, sub_struct, field_name );
  
  eval( cmd );
end

end