use v6;

use XML;
use deredere;

# Test case 2: fetch pull requests titles in first 10 pages of some github profile.
sub parser($doc) {
    # Names of pull-requests from page.
    my $cells = $doc.lookfor(:TAG<div>, :class<repository-content>, :SINGLE).lookfor(:TAG<div>, :class<table-list-cell>);
    $cells.map({$_.lookfor(:TAG<a>, :FIRST)[0][0]});
}
sub next($doc) {
    # Definetly slow, but concise.
    $doc.lookfor(:TAG<a>, :rel<nofollow>)[*-1]<href>;
};
sub operator(@pull) {
    my $fh = open "testfile", :a;
    for @pull {
	$fh.say($_);
    }
    $fh.close;
};

scrape("github.com/supernovus/exemel/commits/master", &parser, &operator, &next, 2);
