use Test;
use WebServices::GitHub;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my $gh = WebServices::GitHub.new;
    my $user = $gh.request('/users/fayland').data;
    is $user<login>, 'fayland', 'login ok';
    is $user<name>, 'Fayland Lam', 'name ok';
}

done-testing();