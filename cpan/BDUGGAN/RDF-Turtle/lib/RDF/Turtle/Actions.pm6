unit class RDF::Turtle::Actions;

my class URI {
    has Str $.base = '';
    has Str $.rel;
    has Str $.abs;
    method raw {
        $.abs // ($.base ~ $.rel)
    }
    method Str {
        '<' ~ self.raw ~ '>'
    }
}
has %.prefixes is default('/');
has @.blanks;
has URI $.current-base is rw;
method set-base(*%args) {
    self.current-base = URI.new(|%args)
}

method TOP($/) {
   my @triples = $<statement>.map({|.made});
   $/.make: @triples;
}

method statement($/) {
    with $<triples> -> $t {
        $/.make: $t.made
    } else {
        $/.make: Slip.new
    }
}

method directive($/) {
    # child nodes do the necessary work
}

method prefixID($/) {
    my $prefix = ~( $<prefix> // '_noprefix' );
    %.prefixes{ $prefix } = $<uriref>.made.rel;
}

method base($/) {
    self.current-base = $<uriref>.made;
}

method triples($/) {
    my $subject = $<subject>.made or die "no subject";
    my @triples;
    for $<predicateObjectList>.made -> $pair {
        @triples.push: ( $subject, |@$pair );
    }
    $/.make: @triples;
}

method predicateObjectList($/) {
    my @pairs;
    for @$<verb> Z @$<objectList> -> ($v, $o) {
        for $o.made -> $obj {
            @pairs.push: ( $v.made, $obj );
        }
    }
    $/.make: @pairs;
}

method blank($/) {
    $/.make: '_:genid' ~ ++$;
}

method verb($/) {
    if "$/" eq 'a' {
        $/.make: URI.new(abs => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type');
        return;
    }
    $/.make: $<predicate>.made;
}

method predicate($/) {
    $/.make: $<resource>.made;
}

method objectList($/) {
    $/.make: $<object>.map: { .made }
}

method object($/) {
    $/.make: $<resource>.made // $<blank>.made // $<literal>.made;
}

method literal($/) {
    $/.make: $<quotedString>.made
        // $<integer>.made
        // $<double>.made
        // $<decimal>.made
        // $<boolean>.made
        // $<datatypeString>.made
}

method decimal($/) {
    $/.make: $/.Rat;
}

method datatypeString($/) {
    $/.make: "$/";
}

method boolean($/) {
    given "$/".lc {
        when 'true' { $/.make: True }
        when 'false' { $/.make: False }
    }
}

method quotedString($/) {
    $/.make: "{$<string> // ''}";
}

method subject($/) {
    $/.make: $<resource>.made // $<blank>.made;
}

method resource($/) {
    $/.make: $<uriref>.made // $<qname>.made
}

method uriref($/) {
    my $rel = ~$<relativeURI>;
    my $base = '';
    if (not $rel.starts-with('http') and self.current-base ) {
        $base = self.current-base.raw;
    }
    $/.make: URI.new( :$rel, :$base );
}

method qname($/) {
    my $prefix-abbr = ~( $<prefixName> // '_noprefix' );
    my $rel = ~( $<name> // '_noname' );
    my $prefix = %.prefixes{ $prefix-abbr };
    my $base = '';
    if (not $rel.starts-with('http') and self.current-base ) {
        $base = self.current-base.raw;
    }
    $/.make: URI.new(:$base, rel => "$prefix$rel");
}
