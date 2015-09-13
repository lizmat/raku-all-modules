use CSS::Writer;

use Test;

##my $docs = CSS::Writer.^methods.map({.candidates}).map({.WHY}).grep({.defined}).map({.Str});

my @docs = 'lib/CSS/Writer.pm'.IO.slurp.lines.grep({ m/ '#|' \s* (.*)? $/}).map({ ~$0 });

for @docs -> $doc {

    my $writer = CSS::Writer.new( :terse );

    if $doc ~~ /:s $<output>=[.*?] ':=' $<synopsis>=[.*?] $/ {
        my $expected = ~$<output>;
        for split(/ \s+ or \s+ /, $<synopsis>) -> $code-sample {
            my $code = $code-sample.subst( / '$.' /, '$writer.');
            my $out;
            lives-ok { $out = EVAL $code }, "compiles: $code"
                and is $out, $expected, "output is $expected";
        }
    }
}


done-testing;
