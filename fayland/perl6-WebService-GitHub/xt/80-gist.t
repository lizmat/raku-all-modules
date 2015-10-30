use Test;

die 'export GITHUB_ACCESS_TOKEN' unless %*ENV<GITHUB_ACCESS_TOKEN>;

use WebServices::GitHub::Gist;

my $gist = WebServices::GitHub::Gist.new(
    access-token => %*ENV<GITHUB_ACCESS_TOKEN>
);

my $res = $gist.create_gist({
    description => 'Test from perl6 WebServices::GitHub::Gist',
    public => True,
    files => {
        'test.txt' => {
            content => "Created on " ~ now
        }
    }
});
my $data = $res.data;
ok( $data );
my $id = $data<id>;
ok $data<description>;
ok $data<public>;
ok index($data<files>{'test.txt'}<content>, 'Created on').defined;

# for update
diag "Test update";
$res = $gist.update_gist($id, {
    files => {
        "test_another.txt" => {
            content => "Updated on " ~ now
        }
    }
});
$data = $res.data;
ok( $data );
is $data<id>, $id;
ok index($data<files>{'test_another.txt'}<content>, 'Updated on').defined;

# $res = $gist.delete_gist($id);
# diag $res.perl;
# ok $res.is-success; # 204

done-testing;