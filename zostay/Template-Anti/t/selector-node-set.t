#!/usr/bin/env perl6

use v6;

use Test;
use Template::Anti::Selector;

my $ns = Template::Anti::Selector::NodeSet.new;
$ns.put(1);
$ns.put(2);
$ns.put(1);
$ns.put(3);
$ns.put(1);

my @list = $ns.to-list;

diag @list.perl;

is @list.elems, 3, '3 elems';
is @list[0], 1, 'first is 1';
is @list[1], 2, 'second is 2';
is @list[2], 3, 'third is 3';

done;

