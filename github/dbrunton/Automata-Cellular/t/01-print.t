use v6;
use Test;
use lib 'lib';
use Automata::Cellular;

plan 4;

my Wolfram $w .= new(:number(30));

ok ~$w.rule ~~ m:s/Rule 30/, "Prints the rule";
ok +$w.rule == 30, "Numeric rule";
ok $w.rule.hash<001> == 1, "Rule hash is correct";
$w.succ;
ok $w.current ~~ m/ XXX /, "Next stage is corect";
