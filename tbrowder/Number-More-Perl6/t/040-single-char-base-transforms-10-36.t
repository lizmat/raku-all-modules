use v6;
use Test;

use Number::More :ALL;

plan 54;

# testing single chars only
my $prefix = True;
my $LC     = True;

my $base;
my $last-base = 36;

# special cases
$base = 10;
for 10..36 -> $dec {
    ++$base;
    last if $base > $last-base;

    my $digit-idx = $base - 1; # index into @dec2digit

    my $bo = $base;
    my $bi = 10;

    # use exact definitions of the decimal number in the desired output base
    # use @dec2digit
    my $tnum-in  = $dec;
    my $tnum-out = @dec2digit[$digit-idx];

    die "FATAL: Output number is NOT a single char." if $tnum-out.chars != 1;

    # special cases
    if $bo eq '2' {
        my $out = '0b' ~ $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$prefix), $out, $out;
    }
    elsif $bo eq '8' {
        my $out = '0o' ~ $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$prefix), $out, $out;
    }
    elsif $bo eq '16' {
        my $out = '0x' ~ $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$prefix), $out, $out;
        $out = '0x' ~ lc $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$prefix, :$LC), $out, $out;
        $out = lc $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$LC), $out, $out;
    }
    elsif $bo > 10 && $bo < 37 {
        # bases 11 through 36 are NOT case sensitive
        my $out = lc $tnum-out;
        is rebase($tnum-in, $bi, $bo, :$LC), $out, $out;
    }
}

# default
$base = 10;
for 10..36 -> $dec {
    ++$base;
    last if $base > $last-base;

    my $digit-idx = $base - 1; # index into @dec2digit

    my $bo = $base;
    my $bi = 10;

    # use exact definitions of the decimal number in the desired output base
    # use @dec2digit
    my $tnum-in  = $dec;
    my $tnum-out = @dec2digit[$digit-idx];

    die "FATAL: Output number is NOT a single char." if $tnum-out.chars != 1;

    # default case
    is rebase($tnum-in, $bi, $bo), $tnum-out, $tnum-out;
}
