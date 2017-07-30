
use Test;
use Getopt::Advance;

plan 4;


my $ret = getopt(["-h", '-v', '-c', 5, "?"], "hvc:");
my $optset = $ret.optionset;

$optset.set-annotation('h', 'print this help');
$optset.set-annotation('v', 'print program version');

ok $optset<h>, " set help";
ok $optset<v>, " set version";
nok $optset<?>, " set ?";
is $optset<c>, 5, ' set c';
