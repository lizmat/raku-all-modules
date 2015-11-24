use v6;
use Test;
use Crust::Middleware::Session;
use Cookie::Baker;

my &app = sub (%env) {
    return [ 200, [ "Content-Type" => "text/plain" ], [ "Hello, World!" ] ];
};

subtest {
    dies-ok {
        Crust::Middleware::Session::SimpleSession.new()
    }, "id should be required, so arg-less new() should die";

    lives-ok {
        my $s = Crust::Middleware::Session::SimpleSession.new(:id("foo"));
        $s.id = "bar";
    }, "can change id";
}, "SimpleSession";

subtest {
    dies-ok { Crust::Middleware::Session.new() }, "missing :store dies";
    lives-ok { Crust::Middleware::Session.new(
        &app,
        :store(Crust::Middleware::Session::Store::Memory.new())
    ) }, ":store exists, lives";
}, "instantiation";

subtest {
    my $mw = Crust::Middleware::Session.new(
        &app,
        :store(Crust::Middleware::Session::Store::Memory.new())
    );

    is $mw.cookie-name, "crust-session", "default value for cookie-name";
    is $mw.path, "/";
    is $mw.keep-empty, True;
    is $mw.secure, False;
    is $mw.httponly, False;
    ok $mw.sid-generator;
    ok $mw.sid-validator;
}, "default values";

subtest {
    my $cookie-name = "crust-session-test";
    my $domain      = "crust.p6.org";
    my $path        = "/foo/bar/";
    my $mw = Crust::Middleware::Session.new(
        &app,
        :cookie-name($cookie-name),
        :domain($domain),
        :path($path),
        :store(Crust::Middleware::Session::Store::Memory.new()),
    );

    my %env = (
        HTTP_COOKIE => "",
    );
    my @res = $mw.(%env);

    my %h = @res[1];
    for %h.kv -> $k, $v {
        if $k !~~ "Set-Cookie" {
            next;
        }
        my %data = crush-cookie($v);

        like %data{$cookie-name}, rx/^ <[0..9,a..f]>**40 $/;
        is   %data<domain>,       $domain;
        is   %data<path>,         $path;
    }
}, "Call middleware";

done-testing;
