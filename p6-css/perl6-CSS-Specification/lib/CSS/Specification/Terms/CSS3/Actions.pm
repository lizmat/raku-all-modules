use v6;

use CSS::Specification::Terms::Actions;

class CSS::Specification::Terms::CSS3::Actions
    is CSS::Specification::Terms::Actions {
    has @._proforma = 'inherit', 'initial';

    method resolution:sym<dim>($/)        { make $.token($<num>.ast, :type($0.lc) ) }
    method dimension:sym<resolution>($/)  { make $<resolution>.ast }
}
