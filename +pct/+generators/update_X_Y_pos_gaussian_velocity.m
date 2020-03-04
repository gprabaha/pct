function [X_pos, Y_pos] = update_X_Y_pos_gaussian_velocity(current_time, origin, destination, total_time)

if isempty(origin)
  origin = [nan; nan];
  destination = [nan; nan];  
elseif isempty(destination)
  origin = [nan; nan];
  destination = [nan; nan];
end

half_time = total_time/2;
st_dev = half_time/3;
total_dist = norm( destination - origin );

path_vec = destination - origin;
x_axis_unit_vec = [1; 0];
y_axis_unit_vec = [0; 1];
x_proj_coeff = dot( path_vec, x_axis_unit_vec ) / (norm( path_vec ) * norm( x_axis_unit_vec ));
y_proj_coeff = dot( path_vec, y_axis_unit_vec ) / (norm( path_vec ) * norm( y_axis_unit_vec ));

area_under_curve = gaussian_cdf_area( total_time, half_time, st_dev );
mult_const = total_dist/area_under_curve;

if current_time > total_time
  dist_covered = total_dist;
else
  dist_covered = mult_const * gaussian_cdf_area( current_time, half_time, st_dev );
end
X_pos = origin(1) + dist_covered * x_proj_coeff;
Y_pos = origin(2) + dist_covered * y_proj_coeff;

end

function area_between_points = gaussian_cdf_area(current_time, dist_mean, st_dev)

area_between_points = normcdf(current_time, dist_mean, st_dev) - ...
  normcdf(0, dist_mean, st_dev);

end