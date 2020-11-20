function deg = px2deg_from_config(px, conf)

screen = conf.SCREEN;
dist = screen.physical_distance_cm;
height = screen.physical_height_cm;
vres = screen.rect(4) - screen.rect(2);  % vertical resolution

deg = pct.util.px2deg( px, height, dist, vres );

end