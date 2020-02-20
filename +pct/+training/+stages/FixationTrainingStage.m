classdef FixationTrainingStage < pct.util.TrainingStage
  properties
    Name;
    FixDur;
    FixHoldDur;
    PatchDur;
    
    PercentCorrectThresholdAdvance = 80;
    PercentCorrectThresholdRevert = 20;
    TrialHistorySize = 50;
  end
  
  properties (Access = private)
    history_start_index = 1;
  end
  
  methods
    function obj = FixationTrainingStage(fix_dur, fix_hold_dur, patch_dur)
      obj@pct.util.TrainingStage();
      obj.FixDur = fix_dur;
      obj.FixHoldDur = fix_hold_dur;
      obj.PatchDur = patch_dur;
    end
    
    function apply(obj, program)
      program.Value.training_stage_name = obj.Name;
      fix_square = program.Value.targets.fix_square;
      fix_hold_square = program.Value.targets.fix_hold_square;
      
      num_patches = program.Value.structure.num_patches;
      for i = 1:num_patches
        patch_name = pct.util.nth_patch_stimulus_name( i );
        patch = program.Value.targets.(patch_name);
        patch.Duration = obj.PatchDur;
      end
      
      fix_square.Duration = obj.FixDur;
      fix_hold_square.Duration = obj.FixHoldDur;
    end
    
    function tf = advance(obj, program)
      slice = get_history_slice( obj, program );
      update_history_start_index( obj, slice );
      slice_size = slice(2) - slice(1) + 1;
      
      if ( slice_size < obj.TrialHistorySize )
        tf = false;
        program.Value.last_n_percent_correct = nan;
        return
      end
      
      online_performance = program.Value.online_data_rep.Value( slice(1):slice(2)-1 );
      last_n_perc_correct = check_last_n_percent_corr( obj, online_performance, program );
      program.Value.last_n_percent_correct = last_n_perc_correct;
      if last_n_perc_correct >= obj.PercentCorrectThresholdAdvance
        tf = true;
      else
        tf = false;
      end
    end
    
    function tf = revert(obj, program)
      slice = get_history_slice( obj, program );
      update_history_start_index( obj, slice );
      slice_size = slice(2) - slice(1) + 1;
      
      if ( slice_size < obj.TrialHistorySize )
        tf = false;
        program.Value.last_n_percent_correct = nan;
        return
      end
      
      online_performance = program.Value.online_data_rep.Value( slice(1):slice(2)-1 );
      last_n_perc_correct = check_last_n_percent_corr( obj, online_performance, program );
      program.Value.last_n_percent_correct = last_n_perc_correct;
      if last_n_perc_correct < obj.PercentCorrectThresholdRevert
        tf = true;
      else
        tf = false;
      end
    end
    
    function transition(from, to, direc, program)
      to.history_start_index = numel( program.Value.data.Value ) + 1; % current trial index.
      if direc == 1
        program.Value.rewards.training = program.Value.rewards.training + 0.02;
        if program.Value.rewards.training > 0.3
          program.Value.rewards.training = 0.3;
        end
      elseif direc == -1
        program.Value.rewards.training = program.Value.rewards.training - 0.02;
        if program.Value.rewards.training < 0.15
          program.Value.rewards.training = 0.15;
        end
      end
    end
    
    function slice = get_history_slice(obj, program)
      data = program.Value.data.Value;
      num_trials = numel( data );
      start_index = obj.history_start_index;
      end_index = min( start_index + obj.TrialHistorySize-1, num_trials );
      
      slice = [start_index end_index];
    end
    
    function update_history_start_index(obj, history_slice)
      slice_size = history_slice(2) - history_slice(1) + 1;
      if ( slice_size == obj.TrialHistorySize )
        obj.history_start_index = obj.history_start_index + 1;
      end
    end
    
    function last_n_perc_correct = check_last_n_percent_corr(obj, online_performance, program)
      last_n_perc_correct = mean([online_performance(1:end).did_correctly])*100;
      program.Value.last_n_percent_correct = last_n_perc_correct;
    end
  end
end