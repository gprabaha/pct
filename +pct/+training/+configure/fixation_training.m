function fixation_training(manager, program)

stage_name = program.Value.training_data.initial_stage_name;

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
add_stage( manager, pct.training.stages.FixHold13() );
add_stage( manager, pct.training.stages.PatchFix1() );
add_stage( manager, pct.training.stages.PatchFix2() );
add_stage( manager, pct.training.stages.PatchFix3() );
add_stage( manager, pct.training.stages.PatchFix4() );

initialize_stage(manager, stage_name);

end