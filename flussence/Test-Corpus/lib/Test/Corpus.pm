unit module Test::Corpus:auth<github:flussence>:ver<2.0.7>;

use Test;

#| Convenience sub for testing filter functions of arity 1
sub simple-test(&func:(Str --> Str)) is export {
    sub (IO::Path $in, IO::Path $out, Str $testcase) {
        is &func($in.slurp), $out.slurp, $testcase;
    }
}

#| Runs tests on a callback. The callback gets passed input/output filehandles,
#| and the basename of the test file being run. Tests are run in no particular
#| order.
sub run-tests(
    &test,
    Str :$basename = $*PROGRAM.basename,
) is export {
    my @files = dir('t_files/' ~ $basename ~ '.input');

    # If you need multiple tests per file, use &Test::subtest. Although I could
    # wrap that around each iteration here for convenience, I prefer the
    # pay-for-what-you-use approach.
    plan +@files;

    &test(.IO, .subst('.input/', '.output/').IO, .basename) for @files;
}

=for anyone-who-knows-what-they're-doing
This module is excruciatingly slow and I'm burned out trying to improve it at
this point. I've tried threading but that just makes Rakudo segfault. Help would
be greatly appreciated.

# vim: set tw=80 :
