use v6;
use Test;
use lib <lib>;

plan 17;

use-ok 'Finance::GDAX::API::URL', 'Finance::GDAX::API::URL useable';
use Finance::GDAX::API::URL;

my $url = Finance::GDAX::API::URL.new;
can-ok $url, 'production-url';
can-ok $url, 'testing-url';
can-ok $url, 'debug';
can-ok $url, 'get-url';
can-ok $url, 'add-to-url';
can-ok $url, 'path';

is $url.debug.WHAT, (Bool), 'Debug is boolean';
is $url.get-url, 'https://api-public.sandbox.gdax.com', 'Default URL is sandbox';
$url.debug = False;
is $url.get-url, 'https://api.gdax.com', 'Production URL is not sandbox';

ok $url.add-to-url('extra_uri'), 'Add extra URI returns';
is $url.get-url, 'https://api.gdax.com/extra_uri', 'Extra URI shows up in URL';
$url.add-to-url('more_uri');
is $url.get-url, 'https://api.gdax.com/extra_uri/more_uri', 'Extra 2 URIs shows up in URL';
$url.add-to-url('sep_uri1/sep_uri2');
is $url.get-url, 'https://api.gdax.com/extra_uri/more_uri/sep_uri1/sep_uri2', 'Slashes work in add in URL';

$url = Finance::GDAX::API::URL.new;
$url.add-to-url('/leading');
is $url.get-url, 'https://api-public.sandbox.gdax.com/leading', '1 added URI with leading / stripped';
$url.add-to-url('///moreleading');
is $url.get-url, 'https://api-public.sandbox.gdax.com/leading/moreleading', 'URI with multiple leading / stripped';
$url.add-to-url('trailing/');
is $url.get-url, 'https://api-public.sandbox.gdax.com/leading/moreleading/trailing', 'URI with trailing / stripped';
