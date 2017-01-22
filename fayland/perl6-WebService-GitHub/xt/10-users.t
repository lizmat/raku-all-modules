use Test;
use WebService::GitHub::Users;
die 'export GITHUB_ACCESS_TOKEN' unless %*ENV<GITHUB_ACCESS_TOKEN>;

my $users = WebService::GitHub::Users.new(
  access-token => %*ENV<GITHUB_ACCESS_TOKEN>
);

ok($users);

my $bio = 'another Perl programmer and Father';

my $u = $users.update({ bio => $bio }).data;

is $u<bio>, $bio, "correctly update bio";

sleep 1;

my $uu = $users.show().data;

is $uu<bio>, $bio, "correctly show bio";

done-testing;
