
use v6;
use Test;
use Duo;
use Duo::Util;

is-deeply Duo.expand(1, 2),         (1→2,),               'expand nothing';
is-deeply Duo.expand([1,2,3], 0),   (1→0, 2→0, 3→0),      'expand keys';
is-deeply Duo.expand(0, [1,2,3]),   (0→1, 0→2, 0→3),      'expand values';
is-deeply Duo.expand([1,2], [3,4]), (1→3, 1→4, 2→3, 2→4), 'expand keys and values';

done-testing;

# vim: ft=perl6
