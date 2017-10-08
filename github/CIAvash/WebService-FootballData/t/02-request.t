use v6;
use Test;
use Test::Mock;
use WebService::FootballData::Role::Request;
use WebService::FootballData::Request;
use WebService::FootballData::Facade::UserAgent;

plan 17;

my $obj = WebService::FootballData::Request.new;
does-ok $obj, WebService::FootballData::Role::Request;
can-ok $obj, 'api_key';
can-ok $obj, 'ua';
isa-ok $obj.ua, WebService::FootballData::Facade::UserAgent;
can-ok $obj, 'base_url';
can-ok $obj, 'get';

my $ua = mocked(
    WebService::FootballData::Facade::UserAgent,
    returning => { get => '{"key": "value"}' }
);

my $request = WebService::FootballData::Request.new: :$ua;

my $base_url = 'http://api.football-data.org/v1';

my $response;
lives-ok { $response = $request.get: 'resource' }, 'request a resource';
check-mock $ua, *.called: 'get', :1times, with => \("$base_url/resource");
is-deeply $response, { key => 'value' }, 'Returns the correct response';

lives-ok { $request.get: 'https://absolute-url' }, 'request an absolute url';
check-mock $ua, *.called: 'get', :1times, with => \<https://absolute-url>;

$request.get: 'resource', :params(query => 'value');
check-mock $ua, *.called: 'get', :1times, with => \("$base_url/resource?query=value");

$request.get: 'resource', :params(query => 'value with space');
check-mock $ua, *.called: 'get', :1times, with => \($base_url ~ '/resource?query=value%20with%20space');

$request.get: 'resource', :params({query => 'value', query2 => 'value2'});
check-mock $ua, *.called: 'get', :1times, with => \("$base_url/resource?query=value&query2=value2");

my $request2 = WebService::FootballData::Request.new: :$ua, :api_key<key>;
$request2.get: 'resource';
check-mock $ua, *.called: 'get', :1times, with => \("$base_url/resource", :X-Auth-Token<key>);

my $request3 = WebService::FootballData::Request.new: :$ua, :content<minified>;
$request3.get: 'resource';
check-mock $ua, *.called: 'get', :1times, with => \("$base_url/resource", :X-Response-Control<minified>);

my $request4 = WebService::FootballData::Request.new: :$ua, :base_url<http://base-url/>;
$request4.get: 'resource';
check-mock $ua, *.called: 'get', :1times, with => \<http://base-url/resource>;