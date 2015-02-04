#!/usr/bin/env perl6

use v6;

BEGIN { @*INC.push: './lib'; }

use Test;
use XML;
use XML::Query;

plan 28;

my $xml = from-xml-file('./t/test1.xml');
my $xq = XML::Query.new($xml);

my $bar = $xq('#two');

ok $bar.defined, 'id query returned a defined result.';
is $bar.WHAT.perl, 'XML::Query::Results', 'query returned correct object type.';

my $foo = $bar.elem;

ok $foo.defined, 'elem() returned a defined value.';
is $foo.WHAT.perl, 'XML::Element', 'elem() returned correct object type.';

is $foo<id>, 'two', 'id query element matches.';
is $foo.nodes.elems, 4, 'id query child element count is correct.';

my $odd = $xq('.odd');
ok $odd.defined, 'class query returned a defined result.';
my @odd = $odd.elems;
ok @odd.elems > 0, 'elems() works.';
is @odd.elems, 5, 'class query returned proper count.';
is @odd[2]<id>, 'two.1', 'class query element matches';

my @two-odd = $xq('#two .odd').elems;
is @two-odd.elems, 2, 'nested query works';

my @two-ids = $xq('#one, #three').elems;
is @two-ids.elems, 2, 'multiple queries works';

my @mixed = $xq('#one .even, #two .even').elems;
is @mixed.elems, 3, 'mixed queries work';
is @mixed[0]<id>, 'one.2', 'mixed query got right element.';
is @mixed[2]<id>, 'two.4', 'mixed query got right element.';

my @by-attr = $xq('lower[class="even"]').elems;
is @by-attr.elems, 4, 'by attr query returns proper count.';
is @by-attr[3]<id>, 'three.2', 'by attr query returns proper element.';

my $by-tag = $xq('upper');
my @by-tag = $by-tag.elems;
is @by-tag.elems, 3, 'query by tag name returns proper count';
is @by-tag[1]<id>, 'two', 'query by tag name returns proper elements.';
my $first-tag = $by-tag.first;
is $first-tag.WHAT.perl, 'XML::Query::Results', 'first returns correct object';
is $first-tag.elem<id>, 'one', 'result of first() method is correct.';
my $last-tag = $by-tag.last.elem;
is $last-tag<id>, 'three', 'result of last() method is correct.';

my $two = $by-tag[1];
is $two.WHAT.perl, 'XML::Query::Results', 'result offset works.';
my $find-two-odd = $two.find('.odd');
is $find-two-odd.WHAT.perl, 'XML::Query::Results', 'find returned results.';
my @find-two-odd = $find-two-odd.elems;
is_deeply @find-two-odd, @two-odd, 'find results are correct.';

my $too-odd = $xq(<.flagged .odd>);
is $too-odd.WHAT.perl, 'XML::Query::Results', 'quoted word returns.';
my @too-odd = $too-odd.elems;
is @too-odd.elems, 2, 'quoted word returned correct number of elems.';

my @too-ids = $xq('#one', '#three').elems;
is @two-ids.elems, 2, 'queries using chained statements works.';

