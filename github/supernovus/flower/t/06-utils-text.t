#!/usr/bin/env perl6

use lib 'lib';

use Test;
use Flower::TAL;

plan 7;

my $xml = '<?xml version="1.0"?>';

## test 1

my $template = '<test><upper tal:content="uc:string:A test of ${name}, in uppercase."/></test>';
my $tal = Flower::TAL.new();

$tal.add-tales('Text');

is ~$tal.parse($template, name => 'Flower'), $xml~'<test><upper>A TEST OF FLOWER, IN UPPERCASE.</upper></test>', 'uc: modifier';

## test 2

$template = '<test><lower tal:content="lc:default">I AM NOT YELLING</lower></test>';

is ~$tal.parse($template), $xml~'<test><lower>i am not yelling</lower></test>', 'lc: modifier';

## test 3

$template = '<test><ucfirst tal:replace="ucfirst:\'bob\'"/></test>';

is ~$tal.parse($template), $xml~'<test>Bob</test>', 'ucfirst: modifier';

## test 4

$template = '<test><substr tal:replace="substr:\'theendoftheworld\' 3 5"/></test>';

is ~$tal.parse($template), $xml~'<test>endof</test>', 'substr: modifier';

## test 5

$template = '<test><substr tal:replace="substr:\'theendoftheworld\' 3 5 1"/></test>';

is ~$tal.parse($template), $xml~'<test>endof...</test>', 'substr: modifier with ellipsis';

## test 6

$template = '<test><substr tal:replace="substr:\'theendoftheworld\' 3"/></test>';

is ~$tal.parse($template), $xml~'<test>endoftheworld</test>', 'substr: modifier without length';

## test 7

$template = '<test><printf tal:replace="printf: \'$%0.2f\' \'2.5\'"/></test>';

is ~$tal.parse($template), $xml~'<test>$2.50</test>', 'printf: modifier';

