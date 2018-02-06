#!/usr/bin/env perl6

class Do::Timeline::Entry {

    has UInt  $.id is rw;

    has Str   $.icon        is required;
    has Str   $.text        is required;
    has UInt  $.daycount    is required;

    method is-past      { $.icon eq '-'; }
    method is-now       { $.icon eq '!'; }
    method is-next      { $.icon eq '+'; }
    method is-pinned    { $.icon eq '^'; }
        
    method render       { $.icon  ~ " [" ~ $.id ~ "]\t" ~ $.text ~ "\n" }
    method set-daycount ($daycount) { $!daycount = $daycount }
}

