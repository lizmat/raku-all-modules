# biggishint.pl6
# Demonstration of the biggishint library, which does arithmetic with
# integers up to 524240 bits long.
#
# To make a stripped shared library from the source code on Linux, do:
#   cc -o biggishint.o -fPIC -c biggishint.c
#   cc -shared -s -o biggishint.so biggishint.o
#   rm biggishint.o
#
# To run this script, use a command line similar to this:
#   PERL6LIB=../lib LD_LIBRARY_PATH=. perl6 biggishint.pl6
# or if you prefer shorter command lines:
#   export PERL6LIB=../lib LD_LIBRARY_PATH=.
#   perl6 biggishint.pl6

use NativeCall;
sub biggishintAdd(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintDivide(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintFromHexadecimalString(Str $s) returns OpaquePointer is native('biggishint') {...}
sub biggishintMultiply(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintSubtract(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintToHexadecimalString(OpaquePointer $bi1) returns Str is native('biggishint') {...}
sub biggishintToDecimalString(OpaquePointer $bi1) returns Str is native('biggishint') {...}

say 'Zavolaj biggishint example: four function biggish (131060 hex digit) calculator.';
say 'Enter a hex expression separated by spaces, such as 1a * 0a, or just . to end.';

loop {
    my ($input, $bi1, $bi2, $bi3);
    $input = prompt 'input : ';
    last if $input eq '.';
    my ($left, $op, $right) = split(' ', $input);
    $bi1 = biggishintFromHexadecimalString($left);
    $bi2 = biggishintFromHexadecimalString($right);
    given $op {
        when '+' { $bi3 = biggishintAdd(      $bi1, $bi2); }
        when '-' { $bi3 = biggishintSubtract( $bi1, $bi2); }
        when '*' { $bi3 = biggishintMultiply( $bi1, $bi2); }
        when '/' { $bi3 = biggishintDivide(   $bi1, $bi2); }
    }
    say biggishintToHexadecimalString($bi3);
}

# end of biggishint.pl6
