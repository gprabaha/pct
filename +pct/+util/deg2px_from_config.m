function px = deg2px_from_config(deg, conf)

screen = conf.SCREEN;
dist = screen.physical_distance_cm;
height = screen.physical_height_cm;
vres = screen.rect(4) - screen.rect(2);  % vertical resolution

px = pct.util.deg2px( deg, height, dist, vres );

end