use v6;
use JSON5::Tiny::Grammar;
use JSON5::Tiny::Actions;
use Test;


my @t =
    '{ "a" : "b\u00E5" }' => { 'a' => 'bå' },
    '[ "\u2685" ]' => [ '⚅' ];

plan (+@t);
for @t -> $p {
    my $a = JSON5::Tiny::Actions.new();
    my $o = JSON5::Tiny::Grammar.parse($p.key, :actions($a));
    is-deeply $o.ast, $p.value, "Correct data structure for «{$p.key}»"
        or say "# Got: {$o.ast.perl}\n# Expected: {$p.value.perl}";
}
