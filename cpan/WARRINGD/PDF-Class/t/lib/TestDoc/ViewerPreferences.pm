use v6;

use PDF::ViewerPreferences;

role TestDoc::ViewerPreferences
    does PDF::ViewerPreferences {
	method some-custom-method {'howdy'}
}
