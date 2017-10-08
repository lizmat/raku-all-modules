use v6;
use Test;

use Number::More :ALL;

plan 61;

# error conditions
#dies-ok { rebase('Z', 40, 3), 2; }, "incorrect base number for input";


my $base      =  2;
my $last-base = 62;

# default
for $base..$last-base -> $base {

    my $digit-idx = $base - 1; # index into @dec2digit

    my $bi = 10;
    my $bo = $base;

    # use exact definitions of the decimal number in the desired output base
    # use @dec2digit
    my $tnum-in  = $base;
    my $tnum-out = @dec2digit[$digit-idx];

    die "FATAL: Output number is NOT a single char." if $tnum-out.chars != 1;

    # default case
    # fake for now
    sub foo() {
	return @dec2digit[$digit-idx];
    }
    is foo(), $tnum-out, $tnum-out;

    # real func:
    #is rebase($tnum-in, $bi, $bo), $tnum-out, $tnum-out;
}
