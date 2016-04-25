use lib 'lib';
use Subset::Helper;

subset Pos of Int where subset-is * >= 0, 'Must be positive';

sub foo (Pos $x) {};

foo -2;