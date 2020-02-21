function start(varargin)

import shared_utils.gui.*;

F = get_figure();
conf = get_config( varargin{:} );

clf( F );

root = MatrixLayout( 1, 2 );

simple_layouts = { 'REWARDS', 'TIMINGS.time_in', 'SCREEN', 'STRUCTURE' };
col1 = root.make_column( 1, numel(simple_layouts), 1 );

for i = 1:numel(simple_layouts)
  layout = simple_layout( col1, simple_layouts{i} );
end

  function layout = simple_layout(parent, fieldname)
    import shared_utils.general.nested_period_substruct;
    
    [subs, split] = nested_period_substruct( fieldname );
    data = subsref( conf, subs );
    
    layout = shared_utils.gui.MatrixLayout();
    layout.panel.Title = lower( split{1} );
    
    parent.push( layout );
    
    dropdown = shared_utils.gui.TextFieldDropdown();
    dropdown.orientation = 'vertical';
    dropdown.on_change = @(varargin) on_change( fieldname, varargin{:} );
    dropdown.parent = layout.panel;
    dropdown.set_data( data );

    function on_change(fieldname, old, new, property)
      import shared_utils.general.nested_period_substruct;
      
      fprintf( '\n Updating "%s".', sprintf('%s.%s', fieldname, property) );
      conf = subsasgn( conf, nested_period_substruct(fieldname), new );
    end
  end
end

function f = get_figure()

persistent F;

if ( isempty(F) || ~isvalid(F) )
  F = figure( 1 );
end

f = F;

end

function conf = get_config(varargin)

conf = pct.config.prune( pct.config.reconcile(varargin{:}) );

end