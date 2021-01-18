function coordinates = assign_patch_coordinates(num_patches, radius, rect)

if num_patches > 4
  error('Number of patches cannot be more than 4!');
end

possible_rotation_angles = 0:30:359;
rect_size = [ rect.X2-rect.X1, rect.Y2-rect.Y1 ];

% Adjusting for rectangular screen
if rect_size(1) > rect_size(2)
  adjustment_ratio = rect_size(2)/rect_size(1);
  adjustment_dim = 1;
else
  adjustment_ratio = rect_size(1)/rect_size(2);
  adjustment_dim = 2;
end

center = [0.5; 0.5];
if num_patches ~= 1
  theta = 360/num_patches;
else
  theta = 0;
end


coordinates = nan( 2, num_patches );
if adjustment_dim == 1
  coordinates( :, 1 ) = [0; radius];
else
  coordinates( :, 1 ) = [radius; 0];
end
if num_patches > 1
  for patch = 2:num_patches
    rotation_matrix = rotation_matrix_generator( theta*(patch-1) );
    coordinates( :, patch ) = rotation_matrix * coordinates( :, 1 );
  end
else
end

random_frame_rotation_angle = randsample( possible_rotation_angles, 1 );
random_angle_frame_rotation_matrix = rotation_matrix_generator( random_frame_rotation_angle );
coordinates = random_angle_frame_rotation_matrix * coordinates;
coordinates(adjustment_dim, :) = coordinates(adjustment_dim, :) * adjustment_ratio;
coordinates = coordinates + center;

end

function rotation_matrix = rotation_matrix_generator(theta)

rotation_matrix = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

end