function state_exit_timestamp(program, state)

program.Value.data.Value(end).(state.Name).exit_time = ...
  elapsed( program.Value.task );

end