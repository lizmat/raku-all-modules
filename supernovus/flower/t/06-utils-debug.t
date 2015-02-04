#!/usr/bin/env perl6

BEGIN { @*INC.push: './lib' }

use Test;
use Flower::TAL;

plan 1;

my $xml = '<?xml version="1.0"?>';

my $template = '<test><dump tal:content="dump:object" tal:attributes="type what:object"/></test>';
my $tal = Flower::TAL.new();

my %ahash = %( {
  'anarray' => [ 'one', 'two', 'three' ],
});

$tal.add-tales('Debug');

is ~$tal.parse($template, object => %ahash), $xml~'<test><dump type="Hash">{"anarray" => ["one", "two", "three"]}</dump></test>', 'dump: and what: modifiers';

