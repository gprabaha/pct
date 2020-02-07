classdef FixationTrainingStage < pct.util.TrainingStage
  properties
    FixDur;
    FixHoldDur;
    PatchDur;
    
    PercentCorrectThresholdAdvance = 85;
    PercentCorrectThresholdRevert = 20;
    TrialHistorySize = 100;
  end
  
  methods
    function obj = FixationTrainingStage(fix_dur, fix_hold_dur, patch_dur)
      obj@pct.util.TrainingStage();
      obj.FixDur = fix_dur;
      obj.FixHoldDur = fix_hold_dur;
      obj.PatchDur = patch_dur;
    end
    
    function apply(obj, program)
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
      online_performance = program.Value.online_data_rep.Value;
      if ( length( online_performance ) >= obj.TrialHistorySize )
        last_n_perc_correct = check_last_n_percent_corr( obj, online_performance );
        if last_n_perc_correct >= obj.PercentCorrectThresholdAdvance
          tf = true;
        else
          tf = false;
        end
      else
        tf = false;
      end
    end
    
    function tf = revert(obj, program)
      online_performance = program.Value.online_data_rep.Value;
      if ( length( online_performance ) >= obj.TrialHistorySize )
        last_n_perc_correct = check_last_n_percent_corr( obj, online_performance );
        if last_n_perc_correct < obj.PercentCorrectThresholdRevert
          tf = true;
        else
          tf = false;
        end
      else
        tf = false;
      end
    end
    
    function last_n_perc_correct = check_last_n_percent_corr(obj, online_performance)
      last_n_perc_correct = mean([online_performance(end-obj.TrialHistorySize+1:end).did_correctly])*100;
    end
  end
end