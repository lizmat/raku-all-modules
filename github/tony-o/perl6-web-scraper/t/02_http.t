#!/usr/bin/env perl6

use Web::Scraper;
use Test;
my $scraper = scraper {
  process 'a', 'tarray[]' => {
    href => sub ($e) {
      return $e.attribs<href> // Any;
    },
    meta => 'TEXT',
  };
}
$scraper.scrape('http://design.perl6.org/S05.html');

my @link = (
  { href => 'https://github.com/perl6/specs/', meta => 'syn' },
  { href => 'http://design.perl6.org/', meta => 'Index of Synopses', },
  { href => '#TITLE', meta => 'TITLE' },
  { href => '#VERSION', meta => 'VERSION' },
);

plan 8;
for 0 .. 3 -> $e {
  ok ($scraper.d<tarray>[$e]<href>//'') eq @link[$e]<href>, "$e href (expected: {@link[$e]<href>}, got: {$scraper.d<tarray>[$e]<href>})";
  ok $scraper.d<tarray>[$e]<meta> eq @link[$e]<meta>, "$e meta text (expected: {@link[$e]<meta>}, got: {$scraper.d<tarray>[$e]<meta>})";
}
