use Test; # -*- mode: perl6 -*-
use WebService::GitHub;
use WebService::GitHub::Issues;

ok(1);

if ( ( %*ENV<TRAVIS> && rate-limit-remaining() ) || %*ENV<GH_TOKEN>  ) {
    diag "running on travis or with token";
    my $gh = WebService::GitHub::Issues.new;
    my $issues = $gh.show(repo => 'fayland/perl6-WebService-GitHub').data;
    cmp-ok $issues.elems, ">", 0, "Non-null number of issues";
    my $first-issue = $gh.single-issue(repo => 'fayland/perl6-WebService-GitHub', issue => 1).data;
    is $first-issue<created_at>, "2015-10-26T19:45:45Z", "First issue OK";
    my @all-issues = $gh.all-issues('JJ/perl6em');
    cmp-ok @all-issues.elems, ">", 0, "Non-null number of issues";
    is @all-issues[1]<state>, "closed", "State of first issue is closed";
}

done-testing();
