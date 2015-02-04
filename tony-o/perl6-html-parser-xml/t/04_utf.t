#!/usr/bin/env perl6

use lib 'lib';
use HTML::Parser::XML;
use Test;
plan 3;

my $html   = slurp 't/data/utf.html';
my $parser = HTML::Parser::XML.new;

$parser.parse($html);

is $parser.xmldoc.root.elements.elems, 2, 'root:elements:elems';
is $parser.xmldoc.root.name, 'html', 'root:tag:html';
is  $parser.xmldoc.root.elements[1].elements[0], 
    $html.subst(/\n+/, ' ', :g) ~~ rx{ '<code>'(.*?)'</code>' }, 
    'html:body:code:♥';
