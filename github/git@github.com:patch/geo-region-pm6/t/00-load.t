use lib 'lib';

use Test;
use Geo::Region;

plan 4;

diag "$*PERL $*VM ($*EXECUTABLE)";

my $obj = Geo::Region.new;
ok $obj.isa(Geo::Region), 'isa Geo::Region';
ok $obj.can('contains'),  'can contains';
ok $obj.can('is-within'), 'can is-within';
ok $obj.can('countries'), 'can countries';
