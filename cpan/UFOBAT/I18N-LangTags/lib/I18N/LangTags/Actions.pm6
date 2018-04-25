class I18N::LangTags::Actions {
    method TOP($/) {
        my %what = $/<disrec_language>:exists
            ?? $/<disrec_language>.made
            !! $/<language>.made;
        make %what;

    }
    method disrec_language($/) {
        make %(
            tag       => $<language><langtag>.made,
            name      => $<language><name>.made,
            is_disrec => True,
        );
    }
    method language($/) {
        make %(
            tag       => $<langtag>.made,
            name      => $<name>.made,
            is_disrec => False,
        );
    }
    method langtag($/) { make $/.Str.lc }
    method name($/) { make $/.Str }

    method scan_languages($/) {
        make $/<TOP>.map( *.made);
    }

    method scan_langtags($/) {
        make $/<langtag>.map( *.made);
    }

    method formerly($/) {
        make $/<langtag>.made;
    }
}
