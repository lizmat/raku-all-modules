# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit module Uni63:ver<0.2.0>;

my constant ENC = @(flat '0'..'9', 'a'..'z', 'A'..'Z');
my constant DEC = %(ENC.pairs.invert);

sub enc1($_) {
    join '', .NFC.map: {
        my @digits;
        my int $cp = $_;
        while $cp {
            @digits.unshift(ENC[$cp % 62]);
            $cp div= 62;
        }
        '_', +@digits, @digits;
    }
}

sub dec1($_) {
    my int $cp = 0;
    for .substr(2).comb {
        $cp *= 62;
        $cp += DEC{$_};
    }
    $cp.chr;
}

our sub enc {
    .ACCEPTS($^s).made given BEGIN /
        ^[ (<[0..9 a..z A..Z]>+ { make ~$/ })
        || (. { make enc1 ~$/ })
        ]*$
        { make $0>>.made.join }
    /;
}

our sub dec {
    .ACCEPTS($^s).made given BEGIN /
        ^[ ((_ (<[0..9]>) <[0..9 a..z A..Z]> ** { +$0 }) { make dec1 ~$0 })
        || (. <-[_]>* { make ~$/ })
        ]*$
        { make $0>>.made.join }
    /;
}
