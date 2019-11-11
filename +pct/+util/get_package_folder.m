
function out = get_package_folder()

%   GET_PACKAGE_FOLDER -- Get the path to the package folder "pct".
%
%       OUT:
%           - `out` (char)

path_components = fileparts( which('pct.util.get_package_folder') );

if ( ispc() )
    slash = '\';
else
    slash = '/';
end

path_components = strsplit( path_components, slash );
path_components = path_components(1:end-1);

out = strjoin( path_components, slash );

end