use v6;
use Test;
plan 4;

# use lib 'lib';

use-ok("Pekyll");
use-ok("Pekyll::Routers");
use-ok("Pekyll::Compilers");

use Pekyll;
my $pekyll = Pekyll.new;
is $pekyll.WHAT.perl, 'Pekyll', 'object create';

