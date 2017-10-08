use v6;
use Locale::US;
use Test;

plan 60;

my @states = all-state-names;
my @codes = all-state-codes;
ok +@states == +@codes, 'Must be the same number of states and codes';

# round-tripping states->codes->states works
for @states -> $s {
    my $c = state-to-code($s);
    my $s2 = code-to-state($c);
    is $s, $s2, "State $s -> $c -> $s2";
}
