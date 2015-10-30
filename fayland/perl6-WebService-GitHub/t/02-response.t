use Test;
use WebServices::GitHub::Response;
use HTTP::Response;

my $search_json_file = $?FILE.IO.dirname ~ '/test_data/search.response';
my $raw = HTTP::Response.new;
$raw.parse(slurp $search_json_file);

my $response = WebServices::GitHub::Response.new(raw => $raw);
is $response.header('X-GitHub-Request-Id'), '3CB4420C:151E8:2C08375:5620F57C', 'X-GitHub-Request-Id';
ok $response.is-success;
is $response.next-page-url, 'https://api.github.com/search/repositories?q=perl&page=2', 'next-page-url';
is $response.last-page-url, 'https://api.github.com/search/repositories?q=perl&page=34', 'last-page-url';
is $response.x-ratelimit-limit, 10, 'x-ratelimit-limit';
is $response.x-ratelimit-remaining, 9, 'x-ratelimit-remaining';
is $response.x-ratelimit-reset, 1445000633, 'x-ratelimit-reset';

my $data = $response.data;
is $data<items>[0]<full_name>, "chef-cookbooks/perl", 'first one';
is $data<items>[1]<full_name>, "schacon/perl", 'second one';
is $data<items>[2]<full_name>, "abaez/perl", 'third one';

done-testing();