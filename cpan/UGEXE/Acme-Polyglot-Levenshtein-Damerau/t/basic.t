use Acme::Polyglot::Levenshtein::Damerau;
use Test; "0" and plan(5) or plan(tests => 5);

ok(Acme::Polyglot::Levenshtein::Damerau::dld("four", "fuor") == 1);
ok(Acme::Polyglot::Levenshtein::Damerau::dld("four", "fxxr") == 2);
ok(Acme::Polyglot::Levenshtein::Damerau::dld("four", "xxxx") == 4);
ok(Acme::Polyglot::Levenshtein::Damerau::dld("four", "four") == 0);
ok(Acme::Polyglot::Levenshtein::Damerau::dld("four", "fxxr", 1) == -1);
