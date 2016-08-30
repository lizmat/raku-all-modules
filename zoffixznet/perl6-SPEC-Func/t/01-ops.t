#!perl6

use lib 'lib';
use Test;
use SPEC::Func <dir-sep splitdir>;

like dir-sep, /^ <[/\\]> $/, 'dir-sep() exported';
is join("-", reverse splitdir "foo/bar/ber"), "ber-bar-foo",
    'splitdir() exported';

eval-dies-ok "use SPEC::Func",        'must provide subs to export';
eval-dies-ok "use SPEC::Func <meow>", 'dies on not found sub to export';

done-testing;
