use lib "lib";
use Test;

use-ok "ProblemSolver::Domain";
use ProblemSolver::Domain;

my $d = ProblemSolver::Domain[1, 2, 3].new;
ok $d, "Instanciated a Domain";

is 		$d.pos,		set(1, 2, 3),	"Domain with the right possibilities";
is 		$d.elems,	3,				"Domain with the right number of possibilities";
my $new = $d.find-and-remove: * == 3;
isnt	$new,		$d,				"find-and-remove return a different obj";
is 		$new.pos,	set(1, 2),		"Domain with the right possibilities";
is 		$new.elems,	2,				"Domain with the right number of possibilities";
$d = $new.remove: 2;
isnt	$d,		$new,				"find-and-remove return a different obj";
is 		$d.pos,	set(1),				"Domain with the right possibilities";
is 		$d.elems,	1,				"Domain with the right number of possibilities";

done-testing;
