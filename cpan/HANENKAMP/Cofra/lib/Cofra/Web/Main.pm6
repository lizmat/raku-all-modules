use v6;

# This resolves some weird Perl6 bug that otherwsise causes some members to
# fail with the mysterious:
#
# Cannot invoke this object (REPR: Null; VMNull)
no precompilation;

use Cofra::Main;

unit class Cofra::Web::Main is Cofra::Main;

use Cofra::IOC;

use Cofra::Web::Controller;
has Hash[Cofra::Web::Controller] $.controllers is constructed;

use Cofra::Web::View;
has Hash[Cofra::Web::View] $.views is constructed;

use Cofra::Web::Router;
use Cofra::Web::Router::PathRouter;
has Cofra::Web::Router $.router is constructed(Cofra::Web::Router::PathRouter);

use Cofra::Web::Controller::Error;
has Cofra::Web::Controller $.error-controller is constructed(Cofra::Web::Controller::Error);

use Cofra::Web;
has Cofra::Web $.web is constructed(dep('web-class')) is construction-args({
    app              => dep,
    controllers      => dep,
    views            => dep,
    router           => dep,
    error-controller => dep,
}) is post-initialized(anon method initialize-web(Cofra::Web:D:) {
    .web = self for |%.controllers.values, |%.views.values, $.router, $.error-controller;
});

method web-class(Cofra::Web::Main:D:) { Cofra::Web }

has Str $.host = 'localhost';
has Int $.port = 5000;

has &.web-app is factory(anon method build-app {
    my $web = $.web;
    sub (%env) {
        start {
            $web.p6wapi-request-response-dispatch(%env);
        }
    }
});

use Smack::Runner;
has Smack::Runner $.web-server is constructed is construction-args({
    app  => dep('web-app'),
    host => dep,
    port => dep,
});


