origin = [5; 5];
destination = [15; 20];
total_time = 0.1;
current_time_vec = linspace(0, total_time*2, 50);

X_pos = [];
Y_pos = [];

for time_pt = current_time_vec
  [X_new_pt, Y_new_pt] = pct.generators.update_X_Y_pos_gaussian_velocity( ...
    time_pt, origin, destination, total_time );
  X_pos = [X_pos, X_new_pt];
  Y_pos = [Y_pos, Y_new_pt];
end

scatter(X_pos,Y_pos);