function state_entry_timestamp(program, state)

program.Value.data.Value(end).(state.Name).entry_time = ...
  elapsed( program.Value.task );

end