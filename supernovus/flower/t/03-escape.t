#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib' }

use Test;
use Flower::TAL;

plan 1;

my $xml = '<?xml version="1.0"?>';

my $template = '<test><escaped tal:content="string"/><unescaped tal:content="structure string"/></test>';
my $tal = Flower::TAL.new();

is ~$tal.parse($template, string=>'hello to you & your friend, "how are you?"'), $xml~'<test><escaped>hello to you &amp; your friend, &quot;how are you?&quot;</escaped><unescaped>hello to you & your friend, "how are you?"</unescaped></test>', 'XML escapes and structure keyword';

