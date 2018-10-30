use lib <lib>;
use Test;

plan 8;

subtest {
    my $test = 't/tests/01-env-smoke.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'without env vars';

    is run-test($test, :AUTOMATED_TESTING),
        "ok 1 - smoke tests run\n1..1\n",
        "with AUTOMATED_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - smoke tests run\n1..1\n",
        "with ALL_TESTING";
}, '<smoke>';

subtest {
    my $test = 't/tests/02-env-smoke-interactive.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'without env vars';

    is run-test($test, :NONINTERACTIVE_TESTING),
        '1..0 # SKIPPING test: To enable smoke tests,'
        ~ " set AUTOMATED_TESTING env var\n",
        'with NONINTERACTIVE_TESTING=1';

    is run-test($test, :AUTOMATED_TESTING, :NONINTERACTIVE_TESTING),
        '1..0 # SKIPPING test: To enable interactive tests,'
        ~ " unset NONINTERACTIVE_TESTING env var\n",
        'with AUTOMATED_TESTING=1 NONINTERACTIVE_TESTING=1';

    is run-test($test, :AUTOMATED_TESTING),
        "ok 1 - smoke + interactive tests run\n1..1\n",
        "with AUTOMATED_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - smoke + interactive tests run\n1..1\n",
        "with ALL_TESTING";
}, '<smoke interactive>';

subtest {
    my $test = 't/tests/03-env-interactive.txt';
    is run-test($test, :NONINTERACTIVE_TESTING),
        '1..0 # SKIPPING test: To enable interactive tests,'
        ~ " unset NONINTERACTIVE_TESTING env var\n",
        'with NONINTERACTIVE_TESTING=1';

    is run-test($test, :AUTOMATED_TESTING),
        "ok 1 - interactive tests run\n1..1\n",
        "without env vars";

    is run-test($test, :ALL_TESTING),
        "ok 1 - interactive tests run\n1..1\n",
        "with ALL_TESTING";
}, '<interactive>';

subtest {
    my $test = 't/tests/04-env-extended.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable extended tests,'
        ~ " set EXTENDED_TESTING or RELEASE_TESTING env var\n",
        'without env vars';

    is run-test($test, :EXTENDED_TESTING),
        "ok 1 - extended tests run\n1..1\n",
        "with EXTENDED_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - extended tests run\n1..1\n",
        "with ALL_TESTING";
}, '<extended>';

subtest {
    my $test = 't/tests/05-env-release.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable release tests,'
        ~ " set RELEASE_TESTING env var\n",
        'without env vars';

    is run-test($test, :RELEASE_TESTING),
        "ok 1 - release tests run\n1..1\n",
        "with RELEASE_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - release tests run\n1..1\n",
        "with ALL_TESTING";
}, '<release>';

subtest {
    my $test = 't/tests/06-env-author.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable author tests,'
        ~ " set AUTHOR_TESTING env var\n",
        'without env vars';

    is run-test($test, :AUTHOR_TESTING),
        "ok 1 - author tests run\n1..1\n",
        "with AUTHOR_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - author tests run\n1..1\n",
        "with ALL_TESTING";
}, '<author>';

subtest {
    my $test = 't/tests/07-env-online.txt';
    is run-test($test),
        '1..0 # SKIPPING test: To enable online tests,'
        ~ " set ONLINE_TESTING env var\n",
        'without env vars';

    is run-test($test, :ONLINE_TESTING),
        "ok 1 - online tests run\n1..1\n",
        "with ONLINE_TESTING";

    is run-test($test, :ALL_TESTING),
        "ok 1 - online tests run\n1..1\n",
        "with ALL_TESTING";
}, '<online>';

subtest {
    my $test = 't/tests/08-env-invalid-keyword.txt';
    is run-test($test),
        " STDERR: ===SORRY!===\nPositional arguments to Test::When can only"
        ~ " be author extended interactive online release smoke\n",
        'without env vars';

    is run-test($test, :ALL_TESTING),
        " STDERR: ===SORRY!===\nPositional arguments to Test::When can only"
        ~ " be author extended interactive online release smoke\n",
        "with ALL_TESTING";
}, 'running with invalid keyword for testing';

done-testing;

sub run-test (Str:D $test, *%vars) {
    # set unused env vars to zero, so the tests of this module are not
    # affected by possible env options set for other modules
    temp %*ENV;
    %*ENV{$_} = (%vars{$_} // 0).Int
        for <AUTOMATED_TESTING
          NONINTERACTIVE_TESTING
          EXTENDED_TESTING
          RELEASE_TESTING
          AUTHOR_TESTING
          ONLINE_TESTING
          ALL_TESTING>;

    my $proc = run :out, :err, $*EXECUTABLE,
        '-Ilib', ('-I' «~« $*REPO.repo-chain.map: *.path-spec),
        $test;

    my ($out, $err) = $proc.out.slurp(:close), $proc.err.slurp: :close;
    return $out unless $err;
    return "$out STDERR: $err";
}
