[![build status](https://secure.travis-ci.org/dankogai/p6-num-hexfloat.png)](http://travis-ci.org/dankogai/p6-num-hexfloat)

# NAME

Num::HexFloat - Rudimentary C99 Hexadecimal Floating Point Support in Perl6

## SYNOPSIS

````perl6
use v6;
use Num::HexFloat;
   
say to-hexfloat(pi);
# '0x1.921fb54442d18p+1'
say from-hexfloat('0x1.921fb54442d18p+1') == pi;
# True
my $src = "e=0x1.5bf0a8b145769p+1, pi=0x1.921fb54442d18p+1";
say $src.subst($RE_HEXFLOAT, &from-hexfloat, :g);
# e=2.71828182845905, pi=3.14159265358979
````

## DESCRIPTION

`Num::HexFloat` exports the following:

### `$RE_HEXFLOAT`

A regex that matches hexadecimal floating point notation.

### `from-hexfloat($arg) returns Num`

Parses `$arg` as a C99 hexadecimal floating point notation and returns
`Num`, or `NaN` if it fails.

`$arg` can be either `Str` or `Match` so you can go like: 

````perl6
$src.subst($RE_HEXFLOAT, &from-hexfloat, :g);
````

### `to-hexfloat(Numeric $num) returns Str`

Stringifies `$num` in C99 hexadecimal floating point notation.

