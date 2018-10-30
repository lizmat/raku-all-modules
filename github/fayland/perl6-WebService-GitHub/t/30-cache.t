use Test;
use WebService::GitHub;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my ($gh, $res, $user, $old_etag, $old_date);

    my $first-test = 0;

    if rate-limit-remaining() {
	$gh = WebService::GitHub.new;
	$res = $gh.request('/users/fayland');
	$user = $res.data;
	is $user<login>, 'fayland', 'login ok';
	is $user<name>, 'Fayland Lam', 'name ok';
	$old_etag = $res.raw.field('ETag').Str;
	$old_date = $res.raw.field('Date').Str;
	$first-test = 0
    }

    if $first-test && rate-limit-remaining() {
	$res = $gh.request('/users/fayland');
	$user = $res.data;
	is $user<login>, 'fayland', 'login ok';
	is $user<name>, 'Fayland Lam', 'name ok';
	my $new_etag = $res.raw.field('ETag').Str;
	my $new_date = $res.raw.field('Date').Str;
	is $old_etag, $new_etag, $old_etag;
	is $new_date, $old_date, $new_date;
    }
}

done-testing();
