function tf = is_second_trial_portion(program)
tf = program.Value.current_patch_sequence_index == 2;
end