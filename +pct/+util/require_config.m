function conf = require_config(conf)

if ( nargin == 0 )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

end