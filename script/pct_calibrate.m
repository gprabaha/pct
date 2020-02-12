function pct_calibrate(conf)

if ( nargin < 1 )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

screen_info = struct();
screen_info.full_rect = [];
screen_info.calibration_rect = conf.CALIB_SCREEN.rect;
screen_info.screen_index = 4; %conf.SCREEN.index;

reward_channel_index = 1;
reward_size = 0.1;

run_calibration( screen_info, reward_channel_index, reward_size );

end