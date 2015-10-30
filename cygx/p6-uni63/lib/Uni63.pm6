# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

unit module Uni63:version<0.1.2>;

my constant ENC = @(flat '0'..'9', 'a'..'z', 'A'..'Z');
my constant DEC = %(ENC.pairs.invert);

our sub enc($_) {
    .subst: :g, / <-[0..9a..zA..Z]> /, {
        my int $cp = .ord;
        my @digits;
        while $cp {
            @digits.unshift(ENC[$cp % 62]);
            $cp div= 62;
        }
        join '', '_', +@digits, @digits;
    }
}

our sub dec($_) {
    .subst: :g, / _ (<[0..9]>) <[0..9a..zA..Z]> ** { +$0 } /, {
        my int $cp = 0;
        for .substr(2).comb {
            $cp *= 62;
            $cp += DEC{$_};
        }
        $cp.chr;
    }
}
