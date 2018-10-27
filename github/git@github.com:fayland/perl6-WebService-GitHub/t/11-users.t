use Test;  # -*- mode: perl6 -*-
use WebService::GitHub;
use WebService::GitHub::Users;

ok(1);

if ( (%*ENV<TRAVIS> && rate-limit-remaining()) || %*ENV<GH_TOKEN>  ) {
    diag "running on travis or with token";
    my $gh-user = WebService::GitHub::Users.new;
    my $user = $gh-user.show("JJ").data;
    is $user<login>, 'JJ', 'User login OK';
    is $user<type>, 'User', 'User type OK'; 
}

done-testing();
