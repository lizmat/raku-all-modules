use v6;

use Test;

use Cofra::App;
use Smack::Runner;

class TestApp is Cofra::App { }

use Cofra::Biz;
class TestApp::Biz::Foo is Cofra::Biz { }
class TestApp::Biz::Bar is Cofra::Biz { }

use Cofra::Web::Controller;
class TestApp::Web::Controller::Foo is Cofra::Web::Controller { }
class TestApp::Web::Controller::Bar is Cofra::Web::Controller { }

use Cofra::Singleton;
use Cofra::Web::Main;
class TestApp::Main is Cofra::Web::Main does Cofra::Singleton['testapp-main'] {
    use Cofra::IOC;

    has TestApp::Biz::Foo $.foo-biz is constructed;
    has TestApp::Biz::Bar $.bar-biz is constructed;

    has Hash[Cofra::Biz] $.bizzes is constructed is construction-args(\(
        'foo', dep('foo-biz'),
        'bar', dep('bar-biz'),
    ));

    method app-class { TestApp }

    has TestApp::Web::Controller::Foo $.foo-c8r is constructed;
    has TestApp::Web::Controller::Bar $.bar-c8r is constructed;

    has Hash[Cofra::Web::Controller] $.controllers is constructed is construction-args(\(
        'foo', dep('foo-c8r'),
        'bar', dep('bar-c8r'),
    ));

    use Cofra::Web::View::JSON;
    has Hash[Cofra::Web::View] $.views is constructed is construction-args(anon method views-args {
        \(
            'JSON', Cofra::Web::View::JSON.new,
        )
    });
}

my $main = TestApp::Main.instance;
ok $main.defined;
isa-ok $main, Cofra::Main;

ok $main.logger.defined;
does-ok $main.logger, Cofra::Logger;

ok $main.bizzes.defined;
isa-ok $main.bizzes, Hash;

ok $main.app.defined;
isa-ok $main.app, TestApp;

is $main.foo-biz.app, $main.app;
is $main.bar-biz.app, $main.app;

ok $main.web.defined;
isa-ok $main.web, Cofra::Web;

ok $main.controllers.defined;
isa-ok $main.controllers, Hash;
is $main.controllers<foo>, $main.foo-c8r;
is $main.controllers<bar>, $main.bar-c8r;
is $main.foo-c8r.web, $main.web;
is $main.bar-c8r.web, $main.web;

ok $main.views.defined;
isa-ok $main.views, Hash;
isa-ok $main.views<JSON>, Cofra::Web::View::JSON;
is $main.views<JSON>.web, $main.web;

ok $main.web-server.defined;
isa-ok $main.web-server, Smack::Runner;

done-testing;
