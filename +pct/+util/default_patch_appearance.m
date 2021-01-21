function info = default_patch_appearance(info)

% Configure the visual properties of a patch here. `info` is a
%   pct.util.PatchInfo object.
%
% See also pct.util.PatchInfo

strategy = info.Strategy;
color = repmat( 255, 1, 3 );

switch ( strategy )
  case 'self'
    if ( ismember('hitch', info.Agent) )
      color = [255, 0, 0];
    elseif ( ismember('algo', info.Agent) )
      color = [0, 255, 0];
    else
      color = [102, 0, 255]; 
    end
    
  case 'compete'
    color = [255, 255, 0];
    
  case 'cooperate'
    color = [0, 255, 255];
end

info.Color = color;

end