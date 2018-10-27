use v6.c;
use Test;

#
# Copyright © 2018 Joelle Maslak
# See License 
#

use Net::Netmask;

my $net1 = Net::Netmask.new('192.168.75.8/29');
my $net2 = Net::Netmask.new('192.168.75.8/29');

ok $net1 == $net2, "Equality of two N::N objects";
ok $net1 eq $net2, "String Equality of two N::N objects";
ok $net1 == 3232254728, "Equality of N::N and Int";
is $net1 cmp $net2, Same, "cmp of two N::N objects";

ok $net1 > 3232254727, "< of N::N and Int";
ok $net1 < 3232254729, "> of N::N and Int";

$net2 = Net::Netmask.new('192.168.75.8/32');
ok $net1 == $net2, "Equality of two N::N objects (diff netmask)";
ok $net1 ne $net2, "String Inequality of two N::N objects (diff netmask)";
is $net1 cmp $net2, Same, "cmp of two N::N objects (diff netmask)";
ok $net1.sk ≠ $net2.sk, "Inequality of two N::N objects (diff netmask)";
ok $net1.sk < $net2.sk, "Same netmask, $net1\.sk < $net2\.sk";

is ($net1, $net2).sort(*.sortkey), ($net1, $net2), "Str Sort in proper order (1) (diff netmask)";
is ($net2, $net1).sort(*.sk), ($net1, $net2), "Str Sort in proper order (2) (diff netmask)";

$net2 = Net::Netmask.new('192.168.75.64/29');
ok $net1 < $net2, ".8 < .64";
ok $net1 ≠ $net2, ".8 ≠ .64";
is $net1 cmp $net2, Less, ".8 < .64";
ok $net1 < $net2, ".8.sk < .64.sk";
ok $net1 ≠ $net2, ".8.sk ≠ .64.sk";
is $net1 cmp $net2, Less, ".8.sk < .64.sk";

$net2 = Net::Netmask.new('4.0.0.0/29');
ok $net1 > $net2, "192 > 10";
ok $net1 ≠ $net2, "192 ≠ 10";
is $net1 cmp $net2, More, "192 cmp 10";
ok $net1.sk > $net2.sk, "192.sk > 10.sk";
ok $net1.sk ≠ $net2.sk, "192.sk ≠ 10.sk";
is $net1.sk cmp $net2.sk, More, "192.sk cmp 10.sk";

multi sub infix:<cmp>(Net::Netmask $lhs, Net::Netmask $rhs) {
    return $lhs <=> $rhs;
}

is ($net1, $net2).sort(*.sortkey), ($net2, $net1), "Str Sort in proper order (1)";
is ($net2, $net1).sort(*.sk), ($net2, $net1), "Str Sort in proper order (2)";

is ($net1, $net2).sort( { $^a <=> $^b } ), ($net2, $net1), "Int Sort in proper order (1)";
is ($net2, $net1).sort( { $^a <=> $^b } ), ($net2, $net1), "Int Sort in proper order (2)";

is Net::Netmask.sort($net1, $net2), ($net2, $net1), "Int N::N::sort in proper order (1)";
is Net::Netmask.sort($net2, $net1), ($net2, $net1), "Int N::N::sort in proper order (2)";

lives-ok { Net::Netmask.sort($net1, $net2) }, "Can't call .sort() on an N::N instance";
dies-ok { $net1.sort($net1, $net2) }, "Can't call .sort() on an N::N instance";

done-testing;

