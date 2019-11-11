function run(program)

task = program.Value.task;
states = program.Value.states;

initial_state = states('new_trial');
run( task, initial_state );

end