use Test;
use WebService::GitHub;

my $gh = WebService::GitHub.new(
    with => ('Debug')
);

# # enable debug
# use WebService::GitHub::Role::Debug;
# $gh does WebService::GitHub::Role::Debug;

my $res = $gh.request('/users/fayland');
my $data = $res.data;
diag $data.perl;
is $data<login>, 'fayland';

done-testing;
