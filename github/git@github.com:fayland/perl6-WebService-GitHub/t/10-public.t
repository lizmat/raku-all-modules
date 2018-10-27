use Test; # -*- mode: perl6 -*-
use WebService::GitHub;

ok(1);

if ((%*ENV<TRAVIS> && rate-limit-remaining()) || %*ENV<GH_TOKEN>  ) {
    diag "running on travis or with token";
    my $gh = WebService::GitHub.new;
    my $user = $gh.request('/users/fayland').data;
    is $user<login>, 'fayland', 'login ok';
    is $user<name>, 'Fayland Lam', 'name ok';
}

done-testing();
