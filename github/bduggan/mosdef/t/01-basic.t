use v6;
use lib 'lib';
use Test;
use Slang::Mosdef;

plan 4;

my $l = lambda { 44 };

my $x = λ { return 99 };

my $m = λ ($n) { $n * 2 };

class Bar {
    def bub {
        return 12;
    }
}


is $l(), 44, 'lambda';
is $x(), 99, "λ";
is $m(3), 6, 'with args';
is Bar.bub, 12, 'method';

