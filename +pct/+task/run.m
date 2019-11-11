
function run(opts)

%   RUN -- Run the task based on the saved config file options.
%
%     IN:
%       - `opts` (struct)

INTERFACE =   opts.INTERFACE;
TIMER =       opts.TIMER;
STIMULI =     opts.STIMULI;
TRACKER =     opts.TRACKER;
WINDOW =      opts.WINDOW;

%   begin in this state
cstate = 'new_trial';
first_entry = true;

while ( true )

  [key_pressed, ~, key_code] = KbCheck();

  if ( key_pressed )
    if ( key_code(INTERFACE.stop_key) ), break; end
  end

  TRACKER.update_coordinates();

  %   STATE new_trial
  if ( strcmp(cstate, 'new_trial') )
    disp( 'entered new trial!' );
    cstate = 'fixation';
    first_entry = true;
  end

  %   STATE fixation
  if ( strcmp(cstate, 'fixation') )
    if ( first_entry )
      disp( 'entered fixation!' );
      %   draw black
      Screen( 'flip', WINDOW.index );
      %   reset state timer
      TIMER.reset_timers( cstate );
      %   get stimulus, and reset target timers
      fix_square = STIMULI.fix_square;
      fix_square.reset_targets();
      %   reset current state variables
      acquired_target = false;
      drew_stimulus = false;
      %   done with initial setup
      first_entry = false;
    end

    fix_square.update_targets();

    if ( ~drew_stimulus )
      fix_square.draw();
      Screen( 'flip', WINDOW.index );
      drew_stimulus = true;
    end

    if ( fix_square.duration_met() )
      disp( 'fixated!' );
      acquired_target = true;
      cstate = 'new_trial';
      first_entry = true;
    end

    if ( TIMER.duration_met(cstate) && ~acquired_target )
      disp( 'failed to acquire fixation target' );
      cstate = 'new_trial';
      first_entry = true;
    end
  end
end

end
	