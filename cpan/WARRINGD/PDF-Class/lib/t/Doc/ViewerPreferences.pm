use v6;

use PDF::ViewerPreferences;

role t::Doc::ViewerPreferences
    does PDF::ViewerPreferences {
	method some-custom-method {'howdy'}
}
