#!perl6

use v6;

use Test;

use lib $*PROGRAM.parent.add('lib').absolute;

use-ok "StaticFoo", "can use an externally defined module";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
