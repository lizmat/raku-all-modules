use v6;

use Test;
use Getopt::Tiny;

subtest {
    my $opts = {};
    temp @*ARGS="--accesslog", "-e", "1", 'x';
    get-options(
        $opts,
        <e=s accesslog=!>
    );
    is-deeply $opts, {:accesslog, :e('1')};
    is-deeply [@*ARGS], ['x'];
}, 'bool';

subtest {
    my $opts;
    get-options(
        $opts,
        <I=s@>,
        ['-Ilib', '-I', 't/lib']
    );
    is-deeply $opts, {I => ['lib', 't/lib']};
}, 'short-str-array';

subtest {
    my $opts;
    get-options(
        $opts,
        <p|port=i>,
        ['-p3']
    );
    is-deeply $opts, {:port(3)};
}, 'short-int-array';

subtest {
    my $opts={};
    temp @*ARGS="-x";
    get-options(
        $opts,
        <p|port=i>,
        ['-x'],
        :pass-through
    );
    is-deeply $opts, {};
    is-deeply [@*ARGS], ['-x'];
}, 'pass-through';

done-testing;
