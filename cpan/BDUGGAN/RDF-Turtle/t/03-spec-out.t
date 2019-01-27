#!perl6

use Test;
use RDF::Turtle::Actions;
use RDF::Turtle::Grammar;

my @tests = $?FILE.IO.dirname.IO.child('tests').dir(test => / 'test-' [ \d+ ] '.ttl' $/);
plan 2 * @tests;

%*ENV<RDF_TURTLE_NO_COLOR> = 1;

for @tests -> $f {
   my $grammar = RDF::Turtle::Grammar.new(:quiet);
   my $actions = RDF::Turtle::Actions.new;
   my $prefix = 'http://www.w3.org/2001/sw/DataAccess/df1/tests/test-00.ttl';
   $actions.set-base(abs => $prefix);

   my $match = $grammar.parse($f.slurp, :$actions);
   ok $match, "parsed { $f.basename }";
   my $triples-file = $f.Str.subst('.ttl','.out').IO;
   my $want = $triples-file.slurp;
   my $made = join "\n", $match.made.map:
         -> ( $x, $y, $z ) { ($x,$y,$z,".").map({ $_ // "Nil" }).join(' ') ~ "\n" };
   if $made.trim eq $want.trim {
       ok True, "correct output for { $f.basename }";
   } else {
       todo $f.basename;
       if %*ENV<TTL_SPEC_TEST> {
          # Be noisier
          is $made.trim, $want.trim, $f.basename;
       } else {
          nok True, "correct output for { $f.basename }";
       }

   }
}

done-testing;

# vim: syn=perl6
