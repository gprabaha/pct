function px = deg2px(deg, h, d, r)

deg_per_px = rad2deg( atan2(0.5*h, d)) / (0.5*r);
px = deg / deg_per_px;

end