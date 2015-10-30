use Test;
use WebService::Google::PageRank;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my $rank = get_pagerank('https://www.google.com/');
    is $rank, "9";
}

done-testing();