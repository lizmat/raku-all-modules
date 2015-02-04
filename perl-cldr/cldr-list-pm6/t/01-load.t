use v6;
use Test;
plan 4;

use CLDR::List;

my $list = CLDR::List.new;

ok $list ~~ CLDR::List,  'instantiate object';
ok $list.can('locale'),  'has locale method';
ok $list.can('format'),  'has format method';
is $list.locale, 'root', 'default locale';
