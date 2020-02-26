function fixation_training(manager)

add_stage( manager, pct.training.stages.Fixation1() );
add_stage( manager, pct.training.stages.Fixation2() );
add_stage( manager, pct.training.stages.Fixation3() );
add_stage( manager, pct.training.stages.Fixation4() );
add_stage( manager, pct.training.stages.Fixation5() );
add_stage( manager, pct.training.stages.FixHold1() );
add_stage( manager, pct.training.stages.FixHold2() );
add_stage( manager, pct.training.stages.FixHold3() );
add_stage( manager, pct.training.stages.FixHold4() );
add_stage( manager, pct.training.stages.FixHold5() );
add_stage( manager, pct.training.stages.FixHold6() );
add_stage( manager, pct.training.stages.FixHold7() );
add_stage( manager, pct.training.stages.FixHold8() );
add_stage( manager, pct.training.stages.FixHold9() );
add_stage( manager, pct.training.stages.FixHold10() );
add_stage( manager, pct.training.stages.FixHold11() );
add_stage( manager, pct.training.stages.FixHold12() );
add_stage( manager, pct.training.stages.FixHold13() );

initialize_stage(manager, 'FixHold1');

end