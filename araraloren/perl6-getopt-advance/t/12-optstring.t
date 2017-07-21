
use Test;
use Getopt::Advance;

plan 4;


my ($optset, @) = getopt(["-h", '-v', '-c', 5, "?"], "hvc:");

$optset.set-annotation('h', 'print this help');
$optset.set-annotation('v', 'print program version');

ok $optset<h>, " set help";
ok $optset<v>, " set version";
nok $optset<?>, " set ?";
is $optset<c>, 5, ' set c';
