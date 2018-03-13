
class Do::Timeline::Entry {

    has UInt  $.id is rw;

    has Str   $.icon        is required;
    has Str   $.text        is required;
    has UInt  $.daycount    is required;

    method is-past      { $.icon eq '-'; }
    method is-now       { $.icon eq '!'; }
    method is-next      { $.icon eq '+'; }
    method is-pinned    { $.icon eq '^'; }
        
    method render       {
		# padding keeps things readable when ID numbers get longer
        my $id-length   = $.id.Str.chars;
		my $padding     = $id-length < 5 
					    ?? ' ' x (5 - $id-length)
					    !! ' ';

		$.icon  ~ " [" ~ $.id ~ "]" ~ $padding ~ $.text ~ "\n" 
	}
    method set-daycount ($daycount) { $!daycount = $daycount }
}

