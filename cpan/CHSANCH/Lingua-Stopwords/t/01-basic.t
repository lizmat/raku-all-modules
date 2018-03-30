use lib <lib>;
use Lingua::Stopwords;
use Testo;

plan 2;

my $stopwords = get-stopwords('en', 'snowball');

is $stopwords.elems, 175, 'got english snowball stopwords';

my $stopwords-es = get-stopwords('es', 'ranks-nl');

is $stopwords-es.elems, 178, 'got english snowball stopwords';
