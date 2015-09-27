unit module Test::Corpus:auth<github:flussence>:ver<2.1.1>;

use Test;

#| Runs tests given a callback function. The optional C<$basename> parameter may
#| be specified to read input/output files from a different location; a test
#| file named "t/example.t" corresponds to "t_files/example.t.{in,out}put/*".
proto sub run-tests(&test, Str :$basename?) is export { * }

#| When given a 3-arg callback, C<run-tests> passes the raw input/output
#| filehandles, and the basename of the test file being run. Tests are run in no
#| particular order, but will be serialised.
multi sub run-tests(&test:($, $, $),
                    Str :$basename = $*PROGRAM.basename) {
    my @files = corpus-for($basename);
    &test(.key, .value, .key.basename) for @files;
}

#| When given a 1-arg callback, it's taken as a simple string filter and assumed
#| to produce no side effects. Tests are run in no particular order, possibly in
#| parallel.
multi sub run-tests(&test:(Str $ --> Str),
                    Str :$basename = $*PROGRAM.basename) {
    my @files = corpus-for($basename);

    is(&test(.key.slurp), .value.slurp, .key.basename) for @files;
}

#| Helper function that sets up plan and grabs testcases. If you need multiple
#| tests per file, use &Test::subtest. Although I could wrap that around each
#| iteration here for convenience, I prefer the pay-for-what-you-use approach.
my sub corpus-for(Str $basename) {
    my @files = dir('t_files/' ~ $basename ~ '.input');
    plan +@files;
    @files.map({ $_ => .subst('.input/', '.output/').IO });
}

#| Wrapper sub for testing filter functions of arity 1. Only here for backwards
#| compatibility, please don't use it.
sub simple-test(&func:(Str --> Str))
        is export is DEPRECATED('run-tests(&callback)') {
    &func;
}

# vim: set tw=80 :
