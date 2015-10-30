use v6;

die 'export GITHUB_USER AND GITHUB_PASS' unless %*ENV<GITHUB_USER> and %*ENV<GITHUB_PASS>;

use WebServices::GitHub::OAuth;

my $gh = WebServices::GitHub::OAuth.new(
    auth_login => %*ENV<GITHUB_USER>,
    auth_password => %*ENV<GITHUB_PASS>
);

# enable debug
use WebServices::GitHub::Role::Debug;
$gh does WebServices::GitHub::Role::Debug;

my $auth = $gh.create_authorization({
    :scopes(['user', 'public_repo', 'repo', 'gist']), # just ['public_repo']
    :note<'test purpose'>
}).data;
say $auth<token>;