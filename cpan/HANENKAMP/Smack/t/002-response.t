#!perl6

use v6;

use Test;
use Smack::Response;

my $res = Smack::Response.new(:status(200), :body([ 'Hello World' ]));
$res.Content-Type = 'text/plain';
$res.Content-Type.charset = 'UTF-8';

is-deeply($res.finalize, [
    200,
    [ Content-Type => 'text/plain; charset=UTF-8' ],
    [ 'Hello World' ],
], 'finalize works');

$res.redirect('/some/place/else');
is($res.redirect, '/some/place/else', 'redirect location works');
is($res.status, 302, 'redirect status works');

is-deeply($res.finalize, [
    302,
    [
        Location => '/some/place/else',
        Content-Type => 'text/plain; charset=UTF-8',
    ],
    [ 'Hello World' ],
], 'finalize redirect works');

my $app = $res.to-app;
is-deeply($app.(), [
    302,
    [
        Location => '/some/place/else',
        Content-Type => 'text/plain; charset=UTF-8',
    ],
    [ 'Hello World' ],
], 'to-app works');

done-testing;
