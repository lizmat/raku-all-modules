#!/usr/bin/env perl6

use Web::Scraper;
use Test;

my $data = q{

<data>
  <t id="1">test1</t>
  <t id="2">test2</t>
  <e>etest</e>
  <t id="3">test3</t>
  <t id="4">test4</t>
  <e>etest</e>
  <nest>
    <id>1</id>
    <val>50</val>
    <sval>1</sval>
    <sval>2</sval>
    <sval>3</sval>
    <sval>43</sval>
  </nest>
  <nest>
    <id>2</id>
    <val>30</val>
    <sval>2</sval>
    <sval>3</sval>
    <sval>5</sval>
    <sval>47</sval>
  </nest>
</data>
};

my $count = 0;
my $scraper = scraper {
  process 't', 'tarray[]' => {
    name => 'TEXT',
    id   => '@id'
  };
  process 'e', 'e[]' => sub ($elem) {
    return "{$elem.contents[0].text ~ $count++}";
  };
  process 't', 'ttext[]' => 'TEXT';
  process 'nest', 'nested[]' => scraper {
    process 'id', 'id' => 'TEXT';
    process 'val', 'val' => 'TEXT';
    process 'sval', 'svals[]' => 'TEXT';
  };
}

$scraper.scrape($data);

plan 20;
$scraper.d.say;

for 0 .. 3 -> $e {
  ok $scraper.d<tarray>[$e]<name> eq "test{1+$e}", 'tarray hash equality';
  ok $scraper.d<tarray>[$e]<id> eq "{1+$e}", 'tarray hash equality';
  ok $scraper.d<ttext>[$e] eq "test{1+$e}", 'ttext array equality';
}

for 0 .. 1 -> $e {
  ok $scraper.d<e>[$e] eq "etest$e", 'text from subroutine equality';
}

my $c = 0;
for @($scraper.d<nested>) -> $e {
  ok $e<id> eq "{$c == 0 ?? '1' !! '2'}", 'nested scrapers';
  ok $e<val> eq "{$c == 0 ?? '50' !! '30'}", 'nested scrapers';
  ok $e<svals>.join("\t") eq "{$c == 0 ?? [1,2,3,43].join("\t") !! [2,3,5,47].join("\t") }", 'nested scrapers';
  $c++;
}
