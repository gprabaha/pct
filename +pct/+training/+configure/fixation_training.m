function fixation_training(manager)

%add_stage( manager, pct.training.stages.Fixation1() );
%add_stage( manager, pct.training.stages.Fixation2() );
%add_stage( manager, pct.training.stages.Fixation3() );
add_stage( manager, pct.training.stages.Fixation4() );
add_stage( manager, pct.training.stages.Fixation5() );
add_stage( manager, pct.training.stages.FixHold1() );
add_stage( manager, pct.training.stages.FixHold2() );
add_stage( manager, pct.training.stages.FixHold3() );
add_stage( manager, pct.training.stages.FixHold4() );
add_stage( manager, pct.training.stages.FixHold5() );
add_stage( manager, pct.training.stages.FixHold6() );


end