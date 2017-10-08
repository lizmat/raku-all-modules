#!/usr/bin/env perl6

use Web::Scraper;
use Test;

my @parts = "$?FILE".split(/\/+|\\+/);
@parts.pop;
chdir @parts.join('/').IO;

my $subscraper = scraper {
  process 'data', 'info' => 'TEXT';
};

my $scraper    = scraper {
  process 'item', 'item[]' => scraper {
    process 'id', 'id' => 'TEXT';
    process 'file', 'file' => 'TEXT';
    resource $subscraper, 'file' => 'TEXT';
  };
};

$scraper.scrape: slurp('data/zero.xml');

$scraper.d.say;

plan 6;

for 0 .. 2 -> $c{
  ok $scraper.d<item>[$c]<id> eq $c+1, "check item id: $c";
  $scraper.d<item>[$c]<info>.say;
  "This is from {$scraper.d<item>[$c]<file>}".say;
  ok $scraper.d<item>[$c]<info> eq "This is from {$scraper.d<item>[$c]<file>.substr(5)}", 'check item description';
}
