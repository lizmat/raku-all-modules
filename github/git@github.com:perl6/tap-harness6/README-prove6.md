# NAME

prove6 - Run tests through a TAP harness.

# USAGE

    prove6 [options] [files or directories]

# OPTIONS

Boolean options:

    -v,                    Print all test lines.
    -l,                    Add 'lib' to the path for your tests (-Ilib).
    -b,                    Add 'blib/lib' to the path for your tests
         --shuffle         Run the tests in random order.
         --ignore-exit     Ignore exit status from test scripts.
         --reverse         Run the tests in reverse order.
         --timer           Print elapsed time after each test.
         --trap            Trap Ctrl-C and print summary on interrupt.
         --help            Display this help
         --version         Display the version


Options that take arguments:

    -e,                    Interpreter to run the tests ('' for compiled
                           tests.)
         --harness         Define test harness to use.  See TAP::Harness.
         --reporter        Result reporter to use. See REPORTERS.
    -j,                    Run N test jobs in parallel (try 9.)
         --err=stdout      Direct the test's $*ERR to the harness' $*ERR.
         --err=merge       Merge test scripts' $*ERR with their $*OUT.
         --err=ignore      Ignore test script' $*ERR.

# NOTES

## Default Test Directory

If no files or directories are supplied, `prove6` looks for all files
matching the pattern `t/*.t`.

## Colored Test Output

Colored test output is the default, but if output is not to a terminal, color
is disabled.
Color support requires `Terminal::ANSIColor` on Unix-like platforms. If the
necessary module is not installed colored output will not be available.

PS: Currently not available.

## Exit Code

If the tests fail `prove6` will exit with non-zero status.

## `-e`

Normally you can just pass a list of Perl 6 tests and the harness will know how
to execute them.  However, if your tests are not written in Perl 6 or if you
want all tests invoked exactly the same way, use the `-e`
switch:

    prove6 -e='/usr/bin/ruby -w' t/
    prove6 -e='/usr/bin/perl -Tw -mstrict -Ilib' t/
    prove6 -e='/path/to/my/customer/exec'

## `--err`

* `--err=stderr`

  Direct the test's `$*ERR` to the harness' `$*ERR`

  This is the default behavior.

* `--err=merge`

  If you need to make sure your diagnostics are displayed in the correct
order relative to test results you can merge the test scripts' `$*ERR` into their `$*OUT`.

  This guarantees that `$*OUT` (where the test results appear) and `$*ERR`
(where the diagnostics appear) will stay in sync.
The harness will
display any diagnostics your tests emit on `$*ERR`.

  Caveat: this is a bit of a kludge. In particular note that if anything
that appears on `$*ERR` looks like a test result, the test harness will
get confused. Use this option only if you understand the consequences
and can live with the risk.

  PS: Currently not supported.

* `--err=ignore`

  Ignore the test script' `$*ERR`


## `--trap`

The `--trap` option will attempt to trap SIGINT (Ctrl-C) during a test
run and display the test summary even if the run is interrupted

## `$*REPO`

`prove6` introduces a separation between "options passed to the perl which
runs prove" and "options passed to the perl which runs tests"; this
distinction is by design. Thus the perl which is running a test starts
with the default `$*REPO`. Additional library directories can be added
via the `PERL6LIB` environment variable, via `-Ifoo` in `PERL6OPT` or
via the `-Ilib` option to `prove6`.
