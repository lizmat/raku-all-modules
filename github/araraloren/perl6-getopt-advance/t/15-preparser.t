
use Test;
use Getopt::Advance;
use Getopt::Advance::Parser;

my OptionSet $preos .= new;

plan 6;

$preos.push(
    'w|weak=s',
);
$preos.push(
    'p|pre=b',
);

my $ret = getopt(["-w", "weak", "-p", "-c", "42", "-q"], $preos, parser => &ga-pre-parser);

ok $preos<p>, "set pre option ok";
is $preos<w>, "weak", "set weak to \"weak\" ok";
is $ret.noa, < -c 42 -q >, "get left command line argument";

$preos.push(
    'c|count=i',
);
$preos.push(
    'q|quit=b',
);

$ret = getopt($ret.noa, $preos);

ok $preos<q>, "set quit option ok";
is $preos<c>, "42", "set count to 42 ok";
is $ret.noa, [ ], "get left command line argument";
