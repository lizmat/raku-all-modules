#!perl6

use v6;

use Test;
use Acme::Insult::Lala;

my $obj;

lives-ok { $obj = Acme::Insult::Lala.new }, "create an instance";

for ^10 {
    my $insult;
    lives-ok { $insult = $obj.generate-insult }, "generate insult";
    ok $insult.defined, "and its defined";
    ok $insult.chars > 5, "and '$insult' has at least five characters";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
