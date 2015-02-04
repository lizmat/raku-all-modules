#!/usr/bin/env perl6

use lib 'lib';
use HTML::Parser::XML;
use Test;

my $html = q{{
  <html>
    <table>
      <tr>tr 1
      <tr>tr 2 - NOT A CHILD
    </table>
  </html>
}};
my $parser = HTML::Parser::XML.new;

$parser.parse($html);
$parser.xmldoc.say;
plan 2;

ok $parser.xmldoc.root.elements[0].elements[1].name eq $parser.xmldoc.root.elements[0].elements[0].name;
ok $parser.xmldoc.root.name eq 'html';
