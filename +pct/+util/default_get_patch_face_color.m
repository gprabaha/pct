function image = default_get_patch_face_color(patch_info, images)

is_self = strcmp( patch_info.Strategy, 'self' );

if ( is_self && strcmp(patch_info.AcquirableBy, 'm2') )
  im_name = sprintf( 'm2_self_reward%d', patch_info.RewardCount );
  
elseif ( is_self && strcmp(patch_info.AcquirableBy, 'm1') )
  im_name = sprintf( 'm1_self_reward%d', patch_info.RewardCount );
  
else
  error( 'No acquired image name specified for strategy "%s" and acquireable-by agents "%s".' ...
    , patch_info.Strategy, strjoin(patch_info.AcquireableBy, ' | ') );
end

match_ind = strcmp( {images.name}, im_name );

if ( nnz(match_ind) ~= 1 )
  error( 'No image matched name "%s".', im_name );
end

image = images(match_ind).image;

end