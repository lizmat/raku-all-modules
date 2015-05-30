use CSS::Writer;

use Test;

for CSS::Writer.^methods.map({.candidates}).map({.WHY}).grep({.defined}).map({.Str}) -> $doc {

    my $writer = CSS::Writer.new( :terse );
    warn :$doc.perl;

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


done();
