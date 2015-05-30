
unit module Inline;

use Inline::C;

multi trait_mod:<is>(Routine $r, :$inline!) is export(:DEFAULT, :traits) {
    my @args;

    # only positional arguments so far
    @args.push( .type ~~ Int ?? 0 !!
                .type ~~ Num ?? 0e0 !!
                .type )
        for $r.signature.params;

    my $code = $r( |@args );

    given $inline {
        when 'C' { $r does Inline::C[$r, $inline, $code] }
        default  { warn "Language '$inline' not supported by Inline module." }
    }
}

