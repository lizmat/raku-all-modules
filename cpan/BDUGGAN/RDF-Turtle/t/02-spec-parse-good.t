#!perl6

use Test;
use RDF::Turtle::Actions;
use RDF::Turtle::Grammar;

%*ENV<RDF_TURTLE_NO_COLOR> = 1;

for $?FILE.IO.dirname.IO.child('tests').dir(test => / 'test-' [ \d+ ] '.ttl' $/) -> $f {
   my $grammar = RDF::Turtle::Grammar.new(:quiet);
   my $match = $grammar.parse($f.slurp);
   ok $match, $f.basename;
   with $grammar.parse-error {
      say .generate-report('error').map({"# $_"}).join("\n");
   }
}
done-testing;

