
function out = get_project_folder()

%   GET_PROJECT_FOLDER -- Get the path to the folder containing the package "pct".
%
%       OUT:
%           - `out` (char)

path_components = fileparts( which('pct.util.get_project_folder') );

if ( ispc() )
    slash = '\';
else
    slash = '/';
end

path_components = strsplit( path_components, slash );
path_components = path_components(1:end-2);

out = strjoin( path_components, slash );

end