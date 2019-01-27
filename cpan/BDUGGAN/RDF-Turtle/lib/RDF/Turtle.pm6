use RDF::Turtle::Grammar;
use RDF::Turtle::Actions;

sub parse-turtle($str) is export {
    my \P = RDF::Turtle::Grammar.new;
    my $actions = RDF::Turtle::Actions.new;
    P.parse($str, :$actions) or die "parse failed";
}
