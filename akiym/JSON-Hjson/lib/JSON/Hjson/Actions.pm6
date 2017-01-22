use v6;
unit class JSON::Hjson::Actions;

method TOP($/) {
    make $<root-object>
        ?? $<root-object>.made.hash.item
        !! $<value>.made;
}

method name($/) {
    make $<json-string>
        ?? $<json-string>.made
        !! $<non-punctuator-char>>>.made.join;
}
method non-punctuator-char($/) { make ~$/ }

method object($/)      { make $<memberlist>.made.hash.item }
method member($/)      { make $<name>.made => $<value>.made }
method memberlist($/)  { make $<member>>>.made.flat }
method root-object($/) { make $<member>>>.made.flat }
method array($/)       { make $<arraylist>.made.item }
method arraylist($/)   { make [$<value>.map(*.made)] }

method value:sym<true>($/)   { make Bool::True  }
method value:sym<false>($/)  { make Bool::False }
method value:sym<null>($/)   { make Any }
method value:sym<object>($/) { make $<object>.made }
method value:sym<array>($/)  { make $<array>.made }
method value:sym<number>($/) { make +$/.Str }
method value:sym<string>($/) { make $<string>.made }

method string:sym<json-string>($/)      { make $<json-string>.made }
method string:sym<multiline-string>($/) {
    my $o = ~$/;
    $o.=subst(/^ "'''" <[\x20\t\r]>* \n?/, '');
    $o.=subst(/\n? <[\x20\t\r]>* "'''" $/, '');

    my sub trim_indent($o, $after) {
        my $indent = $after.subst(/.*\n/, '').chars;
        # XXX subst overwrites $/
        return $o.subst(/^^ \s ** {$indent}/, '', :g);
    }
    make trim_indent($o, $/.prematch);
}
method string:sym<quoteless-string>($/) { make ~$/ }

method json-string($/) {
    make +@$<str> == 1
        ?? $<str>[0].made
        !! $<str>>>.made.join;
}

method str($/) { make ~$/ }

my %h = '\\' => "\\",
        '/'  => "/",
        'b'  => "\b",
        'n'  => "\n",
        't'  => "\t",
        'f'  => "\f",
        'r'  => "\r",
        '"'  => "\"";
method str_escape($/) {
    if $<utf16_codepoint> {
        make utf16.new( $<utf16_codepoint>.map({:16(~$_)}) ).decode();
    } else {
        make %h{~$/};
    }
}
