use lib <lib>;
use Test;

subtest {
    my $test = 't/tests/01-env-smoke.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'without env vars';

    is run-test("AUTOMATED_TESTING=1 perl6 $test"),
        "ok 1 - smoke tests run\n1..1\n",
        "with AUTOMATED_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - smoke tests run\n1..1\n",
        "with ALL_TESTING";
}, '<smoke>';

subtest {
    my $test = 't/tests/02-env-smoke-interactive.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'without env vars';

    is run-test("NONINTERACTIVE_TESTING=1 perl6 $test"),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'with NONINTERACTIVE_TESTING=1';

    is run-test("AUTOMATED_TESTING=1 NONINTERACTIVE_TESTING=1 perl6 $test"),
        '1..0 # SKIPPING test: To enable interactive tests,'
        ~ " unset NONINTERACTIVE_TESTING env var\n",
        'with AUTOMATED_TESTING=1 NONINTERACTIVE_TESTING=1';

    is run-test("AUTOMATED_TESTING=1 perl6 $test"),
        "ok 1 - smoke + interactive tests run\n1..1\n",
        "with AUTOMATED_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - smoke + interactive tests run\n1..1\n",
        "with ALL_TESTING";
}, '<smoke interactive>';

subtest {
    my $test = 't/tests/03-env-interactive.txt';
    is run-test("NONINTERACTIVE_TESTING=1 perl6 $test"),
        '1..0 # SKIPPING test: To enable interactive tests,'
        ~ " unset NONINTERACTIVE_TESTING env var\n",
        'with NONINTERACTIVE_TESTING=1';

    is run-test("AUTOMATED_TESTING=1 perl6 $test"),
        "ok 1 - interactive tests run\n1..1\n",
        "without env vars";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - interactive tests run\n1..1\n",
        "with ALL_TESTING";
}, '<interactive>';

subtest {
    my $test = 't/tests/04-env-extended.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable extended tests,'
        ~ " set EXTENDED_TESTING or RELEASE_TESTING env var\n",
        'without env vars';

    is run-test("EXTENDED_TESTING=1 perl6 $test"),
        "ok 1 - extended tests run\n1..1\n",
        "with EXTENDED_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - extended tests run\n1..1\n",
        "with ALL_TESTING";
}, '<extended>';

subtest {
    my $test = 't/tests/05-env-release.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable release tests,'
        ~ " set RELEASE_TESTING env var\n",
        'without env vars';

    is run-test("RELEASE_TESTING=1 perl6 $test"),
        "ok 1 - release tests run\n1..1\n",
        "with RELEASE_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - release tests run\n1..1\n",
        "with ALL_TESTING";
}, '<release>';

subtest {
    my $test = 't/tests/06-env-author.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable author tests,'
        ~ " set AUTHOR_TESTING env var\n",
        'without env vars';

    is run-test("AUTHOR_TESTING=1 perl6 $test"),
        "ok 1 - author tests run\n1..1\n",
        "with AUTHOR_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - author tests run\n1..1\n",
        "with ALL_TESTING";
}, '<author>';

subtest {
    my $test = 't/tests/07-env-online.txt';
    is run-test("perl6 $test"),
        '1..0 # SKIPPING test: To enable online tests,'
        ~ " set ONLINE_TESTING env var\n",
        'without env vars';

    is run-test("ONLINE_TESTING=1 perl6 $test"),
        "ok 1 - online tests run\n1..1\n",
        "with ONLINE_TESTING";

    is run-test("ALL_TESTING=1 perl6 $test"),
        "ok 1 - online tests run\n1..1\n",
        "with ALL_TESTING";
}, '<online>';

subtest {
    my $test = 't/tests/08-env-invalid-keyword.txt';
    is run-test("perl6 $test"),
        " STDERR: ===SORRY!===\nPositional arguments to Test::When can only"
        ~ " be smoke extended interactive release author online\n",
        'without env vars';

    is run-test("ALL_TESTING=1 perl6 $test"),
        " STDERR: ===SORRY!===\nPositional arguments to Test::When can only"
        ~ " be smoke extended interactive release author online\n",
        "with ALL_TESTING";
}, 'running with invalid keyword for testing';

done-testing;

sub run-test (Str:D $cmd) {
    my $proc = shell $cmd, :out, :err;
    my ($out, $err) = $proc.out.slurp-rest, $proc.err.slurp-rest;
    return $out unless $err;
    return "$out STDERR: $err";
}
