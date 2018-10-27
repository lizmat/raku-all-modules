use v6;
use Lingua::EN::Stopwords::Long;
use Test;

ok is-stop-word('through') == True, "Found stop word";
ok is-stop-word('awesome') == False, "Didn't find non stop word";

done-testing;
