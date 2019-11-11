
function add_depends(conf)

%   ADD_DEPENDS -- Add dependencies as defined in the config file.

if ( nargin < 1 || isempty(conf) )
  conf = pct.config.load();
end

repos = conf.DEPENDS.repositories;
repo_dir = conf.PATHS.repositories;

for i = 1:numel(repos)
  addpath( genpath(fullfile(repo_dir, repos{i})) );
end

end