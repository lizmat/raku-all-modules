use v6;

use Cofra::App;
use Cofra::Main;
use Cofra::Biz;
use Test;

class TestApp is Cofra::App { }

class TestApp::Biz::Foo is Cofra::Biz { }
class TestApp::Biz::Bar is Cofra::Biz { }

use Cofra::Singleton;
class TestApp::Cofra::Main is Cofra::Main does Cofra::Singleton['testapp-main'] {
    use Cofra::IOC;

    has TestApp::Biz::Foo $.foo-biz is constructed;
    has TestApp::Biz::Bar $.bar-biz is constructed;

    has Hash[Cofra::Biz] $.bizzes is constructed is construction-args(\(
        'foo', dep('foo-biz'),
        'bar', dep('bar-biz'),
    ));

    method app-class { TestApp }
}

my $main = TestApp::Cofra::Main.instance;
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

done-testing;
