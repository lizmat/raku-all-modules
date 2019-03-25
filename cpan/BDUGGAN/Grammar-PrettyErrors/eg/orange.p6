use lib $*HOME.child('p6-Grammar-PrettyErrors/lib');
use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    'orange'+ % ' '
  }
}

my $g = G.new(:quiet, :!colors);
$g.parse('orange orange orange banana');
say .parsed with $g.error;

