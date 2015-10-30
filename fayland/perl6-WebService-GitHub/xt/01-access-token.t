use Test;

die 'export GITHUB_ACCESS_TOKEN' unless %*ENV<GITHUB_ACCESS_TOKEN>;

use WebServices::GitHub;

my $gh = WebServices::GitHub.new(
    access-token => %*ENV<GITHUB_ACCESS_TOKEN>
);

my $res = $gh.request('/user');
my $data = $res.data;
diag $data.perl;
ok( $data );
ok( $data<id> );
ok( $data<email> );
ok( $data<login> );
ok( $data<name> );

done-testing;