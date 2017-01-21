use v6;

use Test;
use Test::Builder;

plan 3;

# Verify that module is loaded properly
ok 1, 'Load module';

my Test::Builder $tb .= new;
ok $tb, 'Instance was created';

my Test::Builder $tb_created .= create;
isnt $tb, $tb_created, "Created object isn't existing global singleton"

# vim: ft=perl6
