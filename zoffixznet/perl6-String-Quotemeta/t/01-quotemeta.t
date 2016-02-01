#!perl6

use lib 'lib';
use Test;
use String::Quotemeta;

for 't/code-points.txt'.IO.lines {
    my $code = $_;
    is quotemeta($code.chr), "\\{$code.chr}",
        "Codepoint $_ [{sprintf '%x', $code}]";
    given .chr {
        is quotemeta(), "\\{$code.chr}",
            "Codepoint $code [{sprintf '%x', $code}] # using \$_";
    }
}

my $s;
is Str, quotemeta($s), 'undef warning';

done-testing;
