use v6;

die 'export GITHUB_USER AND GITHUB_PASS' unless %*ENV<GITHUB_USER> and %*ENV<GITHUB_PASS>;

use WebService::GitHub::OAuth;

my $gh = WebService::GitHub::OAuth.new(
    auth_login => %*ENV<GITHUB_USER>,
    auth_password => %*ENV<GITHUB_PASS>
);

# enable debug
use WebService::GitHub::Role::Debug;
$gh does WebService::GitHub::Role::Debug;

my $auth = $gh.create_authorization({
    :scopes(['user', 'public_repo', 'repo', 'gist']), # just ['public_repo']
    :note<'test purpose'>
}).data;
say $auth<token>;