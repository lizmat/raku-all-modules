use v6.c;

use Test;
use P5quotemeta;

my @lines = 't/code-points.txt'.IO.lines;
plan 2 * @lines;

for @lines {
    my $code = $_;
    is quotemeta($code.chr), "\\{$code.chr}",
        "Codepoint $_ [{sprintf '%x', $code}]";
    given .chr {
        is quotemeta(), "\\{$code.chr}",
            "Codepoint $code [{sprintf '%x', $code}] # using \$_";
    }
}

# vim: ft=perl6 expandtab sw=4
