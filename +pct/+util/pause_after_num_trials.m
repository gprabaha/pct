function tf = pause_after_num_trials(program, num_trials)

data = program.Value.data.Value;
if isempty(data)
  elapsed_trials = 0;
else
  elapsed_trials = data(end).trial_index;
end
tf = mod( elapsed_trials, num_trials ) == 0 && elapsed_trials > 0;

end