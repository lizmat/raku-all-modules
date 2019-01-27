
use Test;
use Getopt::Advance;
use Getopt::Advance::Parser;

plan 19;

{
    my OptionSet $preos .= new;

    $preos.push(
        'w|weak=s',
    );
    $preos.push(
        'p|pre=b',
    );
    $preos.insert-cmd("pre");
    $preos.insert-main(
        sub ($os, @args) {
            if +@args == 4 {
                for @args {
                    is .value, < pre -c 42 -q >[.index], "get {.value} from pre-parser";
                }
            } elsif +@args == 1 {
                is @args[0].value, "pre", "get pre from parser";
            }
        }
    );

    my $ret = getopt(["pre", "-w", "weak", "-p", "-c", "42", "-q"], $preos, parser => &ga-pre-parser);

    ok $preos<p>, "set pre option ok";
    is $preos<w>, "weak", 'set weak to "weak" ok';
    is $ret.noa, < pre -c 42 -q >, "get left command line argument";
    is ?$preos.get-cmd("pre").success, True, "we must set the `pre` cmd";

    $preos.push(
        'c|count=i',
    );
    $preos.push(
        'q|quit=b',
    );

    $ret = getopt($ret.noa, $preos);

    ok $preos<q>, "set quit option ok";
    is $preos<c>, "42", "set count to 42 ok";
    is $ret.noa, [ "pre", ], "get left command line argument";
    is ?$preos.get-cmd("pre").success, True, "set pre";
}

{
    my OptionSet @os;
    my OptionSet $os;

    for <help cmd1 cmd2> -> $cmd {
        $os .= new;
        $os.insert-cmd( $cmd );
        @os.push: $os;
    }

    my $rv = getopt( @(<cmd1 -q>), |@os, :parser( &ga-pre-parser ) );

    $os = $rv.optionset;

    is $os.get-cmd{0}.success, True, 'the first cmd is matched ok';
    is $os.get-cmd{0}.name, "cmd1", 'set the cmd1 successfully';
    is $rv.noa, < cmd1 -q >, 'the cmd1 and -q is left in the noa';

    ok $os.get-cmd{0}.reset === Any, 'remember reset the cmd matched before next matching';

    $rv = getopt( @(<cmd2>), |@os );

    $os = $rv.optionset;

    is $os.get-cmd{0}.name, "cmd2", 'get cmd2';
    is $os.get-cmd{0}.success, True, 'set cmd2 ok';
}
