use Test;
use WebServices::GitHub;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my $gh = WebServices::GitHub.new;
    my $res = $gh.request('/users/fayland');
    my $user = $res.data;
    is $user<login>, 'fayland', 'login ok';
    is $user<name>, 'Fayland Lam', 'name ok';
    my $old_etag = $res.raw.field('ETag').Str;
    my $old_date = $res.raw.field('Date').Str;

    $res = $gh.request('/users/fayland');
    $user = $res.data;
    is $user<login>, 'fayland', 'login ok';
    is $user<name>, 'Fayland Lam', 'name ok';
    my $new_etag = $res.raw.field('ETag').Str;
    my $new_date = $res.raw.field('Date').Str;
    is $old_etag, $new_etag, $old_etag;
    is $new_date, $old_date, $new_date;
}

done-testing();
