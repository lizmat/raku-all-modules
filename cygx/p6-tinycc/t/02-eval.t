use Test;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC::Eval;

plan 1;

my $in = 21;
my $out = EVAL :lang<C>, :include<limits.h>, :returns(int32), qq{
    return UINT_MAX + $in + 1;
};

is $out, $in, 'unsigned overflow';
