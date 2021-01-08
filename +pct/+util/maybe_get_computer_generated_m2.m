function maybe_m2 = maybe_get_computer_generated_m2(program)

maybe_m2 = [];
interface = program.Value.interface;

if ( ~interface.has_m2 || ~interface.m2_is_computer )
  return
end

maybe_m2 = program.Value.generator_m2;

end