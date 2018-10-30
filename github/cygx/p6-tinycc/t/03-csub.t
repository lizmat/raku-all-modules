use Test;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC::CSub;

plan 5;

sub mul(int32 \a, int32 \b --> int32) {...} ==> C(q{
    return a * b;
});

ok defined(try &mul.bytes), 'C sub has bytes';
ok defined(try &mul.funcptr), 'C sub has funcptr';
ok mul(3, 4) == 12, 'C sub can be called';

sub get-answer(--> uint64) {...} ==> C(:name<get_answer>, q{
    return 42;
});

ok get-answer() == 42, 'can use alternative name';

sub mysqrt(num64 \val --> num64) {...} ==> C(:include<math.h>, q{
    return sqrt(val);
});

ok mysqrt(2e0) =~= sqrt(2), 'can include math.h';
