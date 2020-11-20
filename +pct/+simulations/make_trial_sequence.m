function trial_sequence = make_trial_sequence(num_patches, n_reps)

if nargin~=2
  error('Too many or too few input parameters!');
end

if (num_patches<2 || num_patches>4)
  error('Too many or too few patches!');
end

% Patch identity legend
%
% 1 -> Self_m1
% 2 -> Self_m2
% 3 -> Competition
% 4 -> Cooperation

switch num_patches
  case 2
    trial_set = nan(2, 10);
    
    ind = 0;
    % Forced reward inequity
    ind = ind+1; trial_set(:, ind) = [1; 1];
    ind = ind+1; trial_set(:, ind) = [1; 2];
    ind = ind+1; trial_set(:, ind) = [2; 2];
    
    % Self and competition
    ind = ind+1; trial_set(:, ind) = [1; 3];
    ind = ind+1; trial_set(:, ind) = [2; 3];
    
    % Self and cooperation
    ind = ind+1; trial_set(:, ind) = [1; 4];
    ind = ind+1; trial_set(:, ind) = [2; 4];
    
    % Competition and cooperation
    ind = ind+1; trial_set(:, ind) = [3; 4];
    
    % Pure competition
    ind = ind+1; trial_set(:, ind) = [3; 3];
    
    % Pure cooperation
    ind = ind+1; trial_set(:, ind) = [4; 4];
    
  case 3
    trial_set = nan(3, 20);
    
    ind = 0;
    % Forced reward inequity
    ind = ind+1; trial_set(:, ind) = [1; 1; 1];
    ind = ind+1; trial_set(:, ind) = [1; 1; 2];
    ind = ind+1; trial_set(:, ind) = [1; 2; 2];
    ind = ind+1; trial_set(:, ind) = [2; 2; 2];
    
    % Self and competition
    ind = ind+1; trial_set(:, ind) = [1, 1, 3];
    ind = ind+1; trial_set(:, ind) = [1, 3, 3];
    ind = ind+1; trial_set(:, ind) = [1, 2, 3];
    ind = ind+1; trial_set(:, ind) = [2, 3, 3];
    ind = ind+1; trial_set(:, ind) = [2, 2, 3];
    
    % Self and cooperation
    ind = ind+1; trial_set(:, ind) = [1, 1, 4];
    ind = ind+1; trial_set(:, ind) = [1, 4, 4];
    ind = ind+1; trial_set(:, ind) = [1, 2, 4];
    ind = ind+1; trial_set(:, ind) = [2, 4, 4];
    ind = ind+1; trial_set(:, ind) = [2, 2, 4];
    
    % Self, competition, and cooperation
    ind = ind+1; trial_set(:, ind) = [1, 3, 4];
    ind = ind+1; trial_set(:, ind) = [2, 3, 4];
    
    % Competition and cooperation
    ind = ind+1; trial_set(:, ind) = [3, 3, 4];
    ind = ind+1; trial_set(:, ind) = [3, 4, 4];
    
    % Pure competition
    ind = ind+1; trial_set(:, ind) = [3, 3, 3];
    
    % Pure cooperation
    ind = ind+1; trial_set(:, ind) = [4; 4; 4];
    
  case 4
    trial_set = nan(4, 21);
    
    ind = 0;
    % Forced reward inequity
    ind = ind+1; trial_set(:, ind) = [1; 1; 1; 2];
    ind = ind+1; trial_set(:, ind) = [1; 1; 2; 2];
    ind = ind+1; trial_set(:, ind) = [1; 2; 2; 2];
    
    % Self and competition
    ind = ind+1; trial_set(:, ind) = [1; 1; 2; 3];
    ind = ind+1; trial_set(:, ind) = [1; 1; 3; 3];
    ind = ind+1; trial_set(:, ind) = [1; 2; 3; 3];
    ind = ind+1; trial_set(:, ind) = [2; 2; 3; 3];
    ind = ind+1; trial_set(:, ind) = [1; 2; 2; 3];
    
    % Self and cooperation
    ind = ind+1; trial_set(:, ind) = [1; 1; 2; 4];
    ind = ind+1; trial_set(:, ind) = [1; 1; 4; 4];
    ind = ind+1; trial_set(:, ind) = [1; 2; 4; 4];
    ind = ind+1; trial_set(:, ind) = [2; 2; 4; 4];
    ind = ind+1; trial_set(:, ind) = [1; 2; 2; 4];
    
    % Self, competition, and cooperation
    ind = ind+1; trial_set(:, ind) = [1; 1; 3; 4];
    ind = ind+1; trial_set(:, ind) = [1; 2; 3; 4];
    ind = ind+1; trial_set(:, ind) = [2; 2; 3; 4];
    
    % Competition and cooperation
    ind = ind+1; trial_set(:, ind) = [3; 3; 3; 4];
    ind = ind+1; trial_set(:, ind) = [3; 3; 4; 4];
    ind = ind+1; trial_set(:, ind) = [3; 4; 4; 4];
    
    % Pure competition
    ind = ind+1; trial_set(:, ind) = [3; 3; 3; 3];
    
    % Pure cooperation
    ind = ind+1; trial_set(:, ind) = [4; 4; 4; 4];
    
end

trial_sequence = repmat( trial_set, 1, n_reps );
trial_sequence = trial_sequence(:, randperm( length( trial_sequence ) ));

end