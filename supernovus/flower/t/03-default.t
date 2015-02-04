#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib' }

use Test;
use Flower::TAL;

plan 2;

my $xml = '<?xml version="1.0"?>';

## test 1

my $template = '<test><i tal:content="default">The default text</i></test>';
my $tal = Flower::TAL.new();

is ~$tal.parse($template), $xml~'<test><i>The default text</i></test>', 'tal:content with default';

## test 2

$template = '<test><i tal:replace="default">The default text</i></test>';

is ~$tal.parse($template), $xml~'<test>The default text</test>', 'tal:replace with default';


