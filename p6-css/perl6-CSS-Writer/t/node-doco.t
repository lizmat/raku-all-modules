use CSS::Writer;

use Test;

##my $docs = CSS::Writer.^methods.map({.candidates}).map({.WHY}).grep({.defined}).map({.Str});

my @docs = 'lib/CSS/Writer.pm'.IO.slurp.lines.grep({ m/ '#|' \s* (.*)? $/}).map({ ~$0 });

my $writer = CSS::Writer.new( :terse, :!color-masks );

for @docs -> $doc {

    if $doc ~~ /:s $<output>=[.*?] ':=' $<synopsis>=[.*?] $/ {
        my $expected = ~$<output>;
        for split(/ \s+ or \s+ /, $<synopsis>) -> $code-sample {
            my $code = $code-sample.subst( / '$.' /, '$writer.');
            my $out;
            lives-ok { $out = EVAL $code }, "compiles/runs: $code"
                and is $out, $expected, "output is $expected";
        }
    }
}


done-testing;
