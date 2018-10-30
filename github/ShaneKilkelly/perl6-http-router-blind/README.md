# HTTP::Router::Blind

A simple, framework-agnostic HTTP Router for Perl6

[![Build Status](https://travis-ci.org/ShaneKilkelly/perl6-http-router-blind.svg?branch=master)](https://travis-ci.org/ShaneKilkelly/perl6-http-router-blind)

## Example

With the HTTP::Easy server:
```perl6
use v6;
use HTTP::Easy::PSGI;
use HTTP::Router::Blind;

my $http = HTTP::Easy::PSGI.new(:port(8080));
my $router = HTTP::Router::Blind.new();

# simple string-match route
$router.get("/", sub (%env) {
    [200, ['Content-Type' => 'text/plain'], ["Home is where the heart is"]]
});

$router.get("/about", sub (%env) {
    [200, ['Content-Type' => 'text/plain'], ["About this site"]]
});

# string match with keyword params,
# the second parameter to the handler function is a hash of params
# extracted from the URL
$router.get("/user/:id", sub (%env, %params) {
    my $user-id = %params<id>;
    [200, ['Content-Type' => 'text/plain'], ["It's user $user-id"]]
});

# regex match, with named capture-group,
# will match a request like '/items/42253',
# the second parameter to the handler is the Regex match object;
$router.get(/\/items\/$<id>=(.*)/, sub (%env, $params) {
    my $id = $params<id>;
    [200, ['Content-Type' => 'text/plain'], ["got request for item $id"]]
});

# you can pass multiple handler functions
# which will be chained together in order
sub do-something-special (%env) { ...; return %env; }
$router.get('/secret', &do-something-special, sub (%env) {
    [200, ['Content-Type' => 'text/plain'], ["it's a secret"]]
});

# in our app function, we just call $router.dispatch
my $app = sub (%env) {
    $router.dispatch(%env<REQUEST_METHOD>, %env<REQUEST_URI>, %env);
};

$http.handle($app);
```

# CHANGELOG

- 2.0.0 : for keyword and regex matches, pass the matched `params` as a second
parameter to the handler function, instead of setting `%env<params>`.
