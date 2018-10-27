use Test;
use WebService::GitHub;
use WebService::GitHub::Role::Debug;
use WebService::GitHub::Role::CustomUserAgent;

my $gh = WebService::GitHub.new();

$gh does WebService::GitHub::Role::Debug;
$gh does WebService::GitHub::Role::CustomUserAgent;
$gh.set-custom-useragent('perl6-WG-test/0.1');

my $res = $gh.request('/users/fayland');
my $ua = $res.raw.request.field('User-Agent');
is $ua, 'perl6-WG-test/0.1';

done-testing;