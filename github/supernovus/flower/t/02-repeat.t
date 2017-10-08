#!/usr/bin/env perl6

use lib 'lib';

use Test;
use Flower::TAL;

plan 9; ## also from outer space.

my $xml = '<?xml version="1.0"?>';

## test 1

my $template = '<test><item tal:repeat="item items" tal:attributes="alt item/alt" tal:content="item/content"/></test>';
my $tal = Flower::TAL.new();
my @items = (
  { :alt<One>,   :content<First>  },
  { :alt<Two>,   :content<Second> },
  { :alt<Three>, :content<Third>  },
);

is ~$tal.parse($template, :items(@items)), $xml~'<test><item alt="One">First</item><item alt="Two">Second</item><item alt="Three">Third</item></test>', 'tal:repeat';

## test 2

$template = '<test><div tal:repeat="item items" tal:omit-tag=""><tr><td tal:content="item/alt"/><td tal:content="item/content"/></tr></div></test>';
is ~$tal.parse($template, :items(@items)), $xml~'<test><tr><td>One</td><td>First</td></tr><tr><td>Two</td><td>Second</td></tr><tr><td>Three</td><td>Third</td></tr></test>', 'tal:repeat with nested elements and omit-tag';

## test 3, Here we test tal:block as well.

$template = '<test><tal:block tal:repeat="item items"><tr><td tal:content="item/alt"/><td tal:content="item/content"/></tr></tal:block></test>';
is ~$tal.parse($template, :items(@items)), $xml~'<test><tr><td>One</td><td>First</td></tr><tr><td>Two</td><td>Second</td></tr><tr><td>Three</td><td>Third</td></tr></test>', 'tal:block used in repeat';

## test 4, Now we're going to test the repeat object.

$template = '<table><tr tal:repeat="row rows"><td tal:repeat="col row"><div tal:define="x repeat/row/number; y repeat/col/number" tal:replace="string:${x} / ${y} = ${col}">row col</div></td></tr></table>';

my @rows = (
  [ '1.1', '1.2', '1.3' ],
  [ '2.1', '2.2', '2.3' ],
  [ '3.1', '3.2', '3.3' ],
);

is ~$tal.parse($template, :rows(@rows)), $xml~'<table><tr><td>1 / 1 = 1.1</td><td>1 / 2 = 1.2</td><td>1 / 3 = 1.3</td></tr><tr><td>2 / 1 = 2.1</td><td>2 / 2 = 2.2</td><td>2 / 3 = 2.3</td></tr><tr><td>3 / 1 = 3.1</td><td>3 / 2 = 3.2</td><td>3 / 3 = 3.3</td></tr></table>', 'nested repeat numbers';

## test 5

$template = '<test><tal:block tal:repeat="item items"><item tal:condition="repeat/item/odd" tal:attributes="id repeat/item/index">Odd</item><item tal:condition="repeat/item/even" tal:attributes="id repeat/item/index">Even</item></tal:block></test>';

is ~$tal.parse($template, :items([1..4])), $xml~'<test><item id="0">Odd</item><item id="1">Even</item><item id="2">Odd</item><item id="3">Even</item></test>', 'repeat with odd and even conditionals';

## test 6

$template = '<test><tal:block tal:repeat="item items"><item tal:condition="repeat/item/start">First</item><item tal:condition="repeat/item/inner">Inner</item><item tal:condition="repeat/item/end" tal:attributes="length repeat/item/length">Last</item></tal:block></test>';

is ~$tal.parse($template, :items([1..4])), $xml~'<test><item>First</item><item>Inner</item><item>Inner</item><item length="4">Last</item></test>', 'repeat with start, end, inner and length.';

## test 7

$template = '<test><tal:block tal:repeat="item items"><item tal:condition="repeat/item/every \'3\'">Every third</item><item tal:condition="repeat/item/skip \'3\'">Normal item</item></tal:block></test>';

is ~$tal.parse($template, :items([1..7])), $xml~'<test><item>Normal item</item><item>Normal item</item><item>Every third</item><item>Normal item</item><item>Normal item</item><item>Every third</item><item>Normal item</item></test>', 'repeat with every and skip';

## test 8

$template = '<test><tal:block tal:repeat="item items"><item tal:condition="repeat/item/lt \'3\'">lt 3</item><item tal:condition="repeat/item/gt \'3\'">gt 3</item><item tal:condition="repeat/item/eq \'3\'">the third</item></tal:block></test>';

is ~$tal.parse($template, :items([1..5])), $xml~'<test><item>lt 3</item><item>lt 3</item><item>the third</item><item>gt 3</item><item>gt 3</item></test>', 'repeat with gt, lt and eq';

## test 9

sub attrmake (*@opts) { @opts.join(' ') | @opts.reverse.join(' ') }

my @options = (
  { value => 'a', label => 'Option 1' },
  { value => 'b', label => 'Option 2', selected => 'selected' },
  { value => 'c', label => 'Option 3' },
);

$template = '<select><option tal:repeat="option options" tal:attributes="value option/value; selected option/selected" tal:content="option/label"/></select>';

my $attrpos = attrmake 'value="b"', 'selected="selected"';

is ~$tal.parse($template, options => @options), $xml~'<select><option value="a">Option 1</option><option '~$attrpos~'>Option 2</option><option value="c">Option 3</option></select>', 'attributes with undefined value';

