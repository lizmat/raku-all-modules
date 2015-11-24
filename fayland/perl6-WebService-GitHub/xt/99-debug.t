use Test;
use WebServices::GitHub;

my $gh = WebServices::GitHub.new(
    with => ('Debug')
);

# # enable debug
# use WebServices::GitHub::Role::Debug;
# $gh does WebServices::GitHub::Role::Debug;

my $res = $gh.request('/users/fayland');
my $data = $res.data;
diag $data.perl;
is $data<login>, 'fayland';

done-testing;
