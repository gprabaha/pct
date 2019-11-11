
function try_add_ptoolbox()

%   TRY_ADD_PTOOLBOX -- Attempt to add Psychtoolbox to Matlab search path.
%
%     This function tries a couple of common Psychtoolbox install
%     directories, in an OS specific way.

has_pt = ~isempty( which('KbName') );

if ( has_pt ), return; end

if ( ismac() )
try_add_paths( {'/Applications/Psychtoolbox'} );
elseif ( ispc() )
try_add_paths( {'C:\toolbox'} );
else
error( 'Unrecognized platform "%s".', computer );
end

end

function tf = try_add_paths(ps)

tf = false;

for i = 1:numel(ps)
if ( ~tf && conditional_addpath(ps{i}) )
    tf = true;
end
end

if ( ~tf )
warning( 'Could not locate Psychtoolbox install.' );
end

end

function tf = conditional_addpath(f)
tf = folder_exists( f );
if ( tf ), addpath( genpath(f) ); end
end

function tf = folder_exists(f)
tf = exist( f, 'dir' ) == 7;
end