function degs = px2deg(pxs, h, d, r)

%   PX2DEG -- Convert pixels to degrees of visual angle.
%
%     deg = px2deg( pxs, h, d, r ); converts pixels `pxs` to degrees
%     `degs`. `h` is the vertical height of the monitor in cm; `d` is the
%     distance from the subject to the monitor in cm; `r` is the vertical
%     resolution of the monitor in pixels.
%
%     See also rad2deg
%
%     Adapted from https://osdoc.cogsci.nl/3.2/visualangle/#convert-pixels-to-visual-degrees

deg_per_px = rad2deg( atan2(0.5*h, d)) / (0.5*r);
degs = pxs * deg_per_px;

end