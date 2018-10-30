#!/usr/bin/env perl6

use lib 'lib';
use HTML::Parser::XML;
use XML::Document;
use Test;

my $html = slurp 't/data/S05.mini.html';
my $parser = HTML::Parser::XML.new;

my $xml = $parser.parse($html);
plan 1;

ok $xml ~~ XML::Document;
