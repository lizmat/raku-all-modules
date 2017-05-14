use Test;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC::Eval;

plan 3;

ok $_ == 1, 'return int32' given do {
    EVAL :lang<C>, :include<limits.h>, :returns(int32), qq{
        return UINT_MAX + 2;
    };
}

ok $_ == 255, 'set bound uint8' given do {
    my $i;
    EVAL 'i = -1;', :lang<C>, :bind(:$i => uint8);
    $i;
}

ok $_ == 4e0, 'get bound num32' given do {
    my $f = 2e0;
    EVAL 'return f * 2;', :lang<C>, :returns(num32), :bind(:$f => num32);
}
