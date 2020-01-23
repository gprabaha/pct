full_rect = [0, 0, 800 800];
cal_rect = [0, 0, 800 800];
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