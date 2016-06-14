use v6;
use Test;
use JSON::Fast;
use WebService::FootballData::Role::UserAgent;
use WebService::FootballData::Facade::UserAgent;

plan 10;

my $obj = WebService::FootballData::Facade::UserAgent.new;
does-ok $obj, WebService::FootballData::Role::UserAgent;
can-ok $obj, 'get';

skip-rest('NETWORK_TESTING is not set') and exit unless %*ENV<NETWORK_TESTING>;

my $response;
lives-ok { $response = $obj.get: 'http://httpbin.org/get?key=value' }, 'Submit get request';
isa-ok $response, Str;
is from-json($response)<args><key>, 'value', 'Has the correct argument';

my $response2 = $obj.get: 'http://httpbin.org/headers', :X-Test<test>;
is from-json($response2)<headers><X-Test>, 'test', 'Has the correct header field';

throws-like {
    $obj.get: 'http://httpbin.org/status/404'
}, X::HTTP::Response, 'Request with 4xx status code should die';
throws-like {
    $obj.get: 'http://httpbin.org/status/500'
}, X::HTTP::Server, 'Request with 5xx status code should die';
dies-ok {
    $obj.get: 'http://httpbin.org/status/204'
}, 'Request with 2xx(except 200) status code should die';

{
    $obj.get: 'http://api.football-data.org/v1/nonexistent';

    CATCH {
        when X::HTTP::Response {
            ok .footballdata_error, 'Exception has a footballdata error message';
        }
    }
}