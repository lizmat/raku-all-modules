use v6;

use XML;
use deredere;

# Test case 1: fetch and save preview images from first konachan's page.
sub src-extractor($node) {
    ($node.Str ~~ /src\=\"(.+?)\"/)[0].Str;
}

sub parser($doc) {
    $doc.lookfor(:TAG<img>).race.map(&src-extractor);
}

scrape("konachan.net/post", &parser);
