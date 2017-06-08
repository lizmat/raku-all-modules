use v6;

use Test;

use LibYAML;
use LibYAML::Parser;
use LibYAML::Loader::TestSuite;

my $DATA = $*PROGRAM.parent.child('data');

my @tests = $DATA.dir.map: { .basename };

my $loader = LibYAML::Loader::TestSuite.new;
my $parser = LibYAML::Parser.new(
    loader => $loader,
);

plan @tests.elems;

#@tests = ('229Q');
for @tests.sort -> $test {
    $loader.events = ();
    my $testdir = $DATA.child($test);

    my $testname = $testdir.child('===').lines[0];

#    diag "$test $testname";

    my $yaml = $testdir.child('in.yaml').Str;
    if $testdir.child('error').e
    {
        diag "$test ERROR";

        throws-like { $parser.parse-file($yaml) },
                    X::LibYAML::Parser-Error,
                    message => /ERROR/;

        next;
    }

    $parser.parse-file($yaml);

    my Str @expected-events = $testdir.child('test.event').lines;
    my Str @events = $loader.events.Array;
    # temp workaround
    @expected-events.map: {
        $_ ~~ s/\+DOC\s\-\-\-/+DOC/;
        $_ ~~ s/\-DOC\s\.\.\./-DOC/;
    };
    @events.map: {
        $_ ~~ s/\+DOC\s\-\-\-/+DOC/;
        $_ ~~ s/\-DOC\s\.\.\./-DOC/;
    };
    is-deeply(@events, @expected-events, "$test - events");


}

done-testing;
