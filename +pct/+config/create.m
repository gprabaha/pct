
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.

if ( nargin < 1 ), do_save = false; end

const = pct.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( pct.util.get_project_folder() );

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'ptb', 'ptb_helpers', 'serial_comm' };

%	INTERFACE
INTERFACE = struct();
INTERFACE.stop_key = ptb.keys.esc();
INTERFACE.use_mouse = true;
INTERFACE.use_reward = false;
INTERFACE.allow_hide_mouse = true;
INTERFACE.is_debug = false;

%	SCREEN
SCREEN = struct();

SCREEN.full_size = get( 0, 'screensize' );
SCREEN.index = 0;
SCREEN.background_color = [ 0 0 0 ];
SCREEN.rect = [ 0, 0, 400, 400 ];

% STRUCTURE
STRUCTURE = struct();
STRUCTURE.num_patches = 10;

%	TIMINGS
TIMINGS = struct();

time_in = struct();
time_in.task = Inf;
time_in.new_trial = 0;
time_in.fixation = 1;
time_in.present_patches = Inf;

TIMINGS.time_in = time_in;

%	STIMULI
STIMULI = struct();
STIMULI.setup = struct();

non_editable_properties = {{ 'placement', 'has_target', 'image_matrix' }};

STIMULI.setup.fix_square = struct( ...
    'class',            'Rect' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 255, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.3 ...
  , 'target_padding',   0 ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.gaze_cursor = struct( ....
    'class',            'Oval' ...
  , 'size',             [ 25, 25 ] ...
  , 'color',            [ 0, 255, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       false ...
  , 'non_editable',     non_editable_properties ...
);

STIMULI.setup.patch = struct( ....
    'class',            'Oval' ...
  , 'size',             [ 50, 50 ] ...
  , 'color',            [ 255, 0, 255 ] ...
  , 'position',         [ 0.5, 0.5 ] ...
  , 'placement',        'center' ...
  , 'has_target',       true ...
  , 'target_duration',  0.3 ...
  , 'target_padding',   10 ...
  , 'non_editable',     non_editable_properties ...
);

%	SERIAL
SERIAL = struct();
SERIAL.port = 'COM3';
SERIAL.channels = { 'A' };

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;
conf.TIMINGS = TIMINGS;
conf.STIMULI = STIMULI;
conf.SCREEN = SCREEN;
conf.INTERFACE = INTERFACE;
conf.STRUCTURE = STRUCTURE;
conf.SERIAL = SERIAL;

if ( do_save )
  pct.config.save( conf );
end

end