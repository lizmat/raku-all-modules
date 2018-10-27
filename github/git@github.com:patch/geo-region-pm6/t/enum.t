use lib 'lib';

use Test;
use Geo::Region::Enum;

plan 8;

is Region::World,           '001', 'world region';
is Region::Europe,          '150', 'continent region';
is Region::EasternEurope,   '151', 'subcontinent region';
is Region::LatinAmerica,    '419', 'grouping region';
is Region::OutlyingOceania, 'QO',  'subcontinent region, CLDR extension';
is Region::EuropeanUnion,   'EU',  'grouping region, CLDR extension';
is Country::Afghanistan,    'AF',  'country';
is Country::ÅlandIslands,   'AX',  'non-ASCII country';
