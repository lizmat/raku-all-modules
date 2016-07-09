use lib 'lib';
use Test;
use Pretty::Topic '♥';

is-deeply ^4 .map({♥ == $_}), True xx 4, '♥ is same as $_ in map';

given 'topic works fine with `when`' {
    when ♥ ~~ /'works fine'/ { pass $_ }
    flunk $_;
}

with 'topic works fine with `with`' {
    when ♥ ~~ /'works fine'/ { pass $_ }
    flunk $_;
}

done-testing;
