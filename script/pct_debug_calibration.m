screen_info = struct();
screen_info.full_rect = [];
screen_info.calibration_rect = [0, 0, 1280, 1024];
screen_info.screen_index = 4;

reward_channel_index = 2;
reward_size = 0.1;

run_calibration( screen_info, reward_channel_index, reward_size );