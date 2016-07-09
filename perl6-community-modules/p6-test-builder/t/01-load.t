use v6;

use Test;
use Test::Builder;

plan 2;

# Verify that module is loaded properly
ok 1, 'Load module';

my Test::Builder $tb .= new;
ok $tb, 'Instance was created';

# vim: ft=perl6
