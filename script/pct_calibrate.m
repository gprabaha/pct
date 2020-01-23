function pct_calibrate(conf)

if ( nargin < 1 )
  conf = pct.config.load();
else
  pct.util.assertions.assert__is_config( conf );
end

full_rect = conf.SCREEN.rect;
cal_rect = conf.SCREEN.rect;

target_size = 50; % px;
n_cal_pts = 5;
screen_index = 0;
skip_sync_tests = 1;

key_callback = @() fprintf('\n Key pressed.' );

Screen( 'Preference', 'skipsynctests', 1 );

try
    calibration.EYECALWin( screen_index, full_rect, cal_rect, target_size, n_cal_pts ...
      , skip_sync_tests, key_callback );
    calibration.cleanup();
catch err
    calibration.cleanup();
    throw( err );
end

end