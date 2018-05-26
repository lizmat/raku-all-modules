
use Test;
use Getopt::Advance;
use Getopt::Advance::Parser;

my OptionSet $preos .= new;

plan 12;

$preos.push(
    'w|weak=s',
);
$preos.push(
    'p|pre=b',
);
$preos.insert-cmd("pre");
$preos.insert-main(
    sub ($os, @args) {
        if +@args == 3 {
            for @args {
                is .value, < -c 42 -q >[.index], "get {.value} from pre-parser";
            }
        } elsif +@args == 1 {
            is @args[0].value, "pre", "get pre from parser";
        }
    }
);

my $ret = getopt(["-w", "weak", "-p", "-c", "42", "-q"], $preos, parser => &ga-pre-parser);

ok $preos<p>, "set pre option ok";
is $preos<w>, "weak", "set weak to \"weak\" ok";
is $ret.noa, < -c 42 -q >, "get left command line argument";
is ?$preos.get-cmd("pre").success, False, "it's ok we not set cmd `pre`";

$preos.push(
    'c|count=i',
);
$preos.push(
    'q|quit=b',
);

$ret = getopt([ "pre", | $ret.noa], $preos);

ok $preos<q>, "set quit option ok";
is $preos<c>, "42", "set count to 42 ok";
is $ret.noa, [ "pre" ], "get left command line argument";
is ?$preos.get-cmd("pre").success, True, "set pre";
