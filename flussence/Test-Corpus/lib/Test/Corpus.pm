module Test::Corpus:auth<github:flussence>:ver<2.0.1>;

use Test;

#| Convenience sub for testing filter functions of arity 1
sub simple-test(&func) is export {
    # ^^ This wants to be "&func:(Str --> Str)"

    return sub (IO::Path $in, IO::Path $out, Str $testcase) {
        is &func($in.slurp), $out.slurp, $testcase;
    }
}

#| Runs tests on a callback. The callback gets passed input/output filehandles,
#  and the basename of the test file being run. Tests are run in no particular
#  order.
sub run-tests(
    &test,
    Str :$basename = $*PROGRAM_NAME.IO.basename,
) is export {
    my @files = dir('t_files/' ~ $basename ~ '.input');

    # If you need multiple tests per file, use &Test::subtest
    plan +@files;

    my sub test-closure($input) {
        return &test.assuming(
            $input.IO,
            $input.subst('.input/', '.output/').IO,
            $input.basename
        );
    }

    @files».&test-closure».();
}

=begin pod
This module would be a good candidate to use threading and I've been trying to
find a way to pull this off for a while:

    await @files».&test-closure».&start;

Ideally everything would run nice and fast and your CPU would burst into flames.

We can't do that (yet) for various reasons:

=item
It just straight up crashes moarvm, before completing the module's own tests
(and worse, some of the ones that do run randomly fail!).

=item
Threads + say/print just don't mix. This code also doesn't seem particularly
amenable to my attempts to override $*OUT with an object that does that, and
just spits everything straight to /dev/stdout regardless. The amount of
difficulty here makes me think I'm trying to solve the thread-safety problem at
the wrong level.

=end pod

# vim: set tw=80 :
