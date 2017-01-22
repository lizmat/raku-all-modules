use v6;
use Test;
use Crust::Builder;
use Crust::Middleware::Session;
use Crust::Test;

my $store = Crust::Middleware::Session::Store::Memory.new();
my &app = builder {
    enable "Session", :store($store), :cookie-name("myapp-session");
    mount "/", -> %env {
CATCH { default { $_.say } }
        my $body = "TOP";
        if my $username = %env<p6sgix.session>.get('username') {
            $body = "TOP: Hello $username";
        }
        [200, [], [$body]];
    };
    mount '/login', -> %env {
        %env<p6sgix.session>.set('username', 'foo');
        [200, [], ["LOGIN"]];
    };
    mount '/counter', -> %env {
        my $counter = %env<p6sgix.session>.get('counter') // 0;
        $counter++;
        %env<p6sgix.session>.set('counter', $counter);
        [200,[],["COUNTER=>" ~ $counter]];
    };
    mount '/logout', -> %env {
        %env<p6sgix.session>.expired = True;
        [200,[],["LOGOUT"]];
    };
};

test-psgi(&app, -> $cb {
    my $first-cookie;
    subtest {
        my $res = $cb(HTTP::Request.new(GET => "http://localhost/"));
        if !is $res.code, 200 {
            $res.content.decode.say;
            return
        }
        if !is $res.content.decode, "TOP" {
            $res.content.decode.say;
            return
        }
        my $set-cookie = $res.field("Set-Cookie");
        if !ok $set-cookie.defined, "cookie header should be defined" {
            return
        }
        $set-cookie.Str ~~ /"myapp-session=" (<[0..9,a..f]>**40) ";"/;
        $first-cookie = $/[0];
    }, "first request";

    if !ok $first-cookie, "first-cookie must be available" {
        return
    }

    subtest {
        my $req = HTTP::Request.new(GET => "http://localhost/login");
        $req.field(|{"Cookie" => "myapp-session=$first-cookie"});
        my $res = $cb($req);
        if !is $res.code, 200 {
            return
        }
        if !is $res.content.decode, "LOGIN" {
            return
        }
        my $set-cookie = $res.field("Set-Cookie");
        if !ok !$set-cookie.defined, "cookie header should NOT be defined" {
            return
        }
    }, "/login";

    subtest {
        my $req = HTTP::Request.new(GET => "http://localhost/");
        $req.field(|{"Cookie" => "myapp-session=$first-cookie"});
        my $res = $cb($req);
        if !is $res.code, 200 {
            return
        }
        if !is $res.content.decode, 'TOP: Hello foo' {
            return
        }
        my $set-cookie = $res.field("Set-Cookie");
        if !ok !$set-cookie.defined, "cookie header should NOT be defined" {
            return
        }
    }, "second request after login";

    for 1..5 -> $i {
        subtest {
            my $req = HTTP::Request.new(GET => "http://localhost/counter");
            $req.field(|{"Cookie" => "myapp-session=$first-cookie"});
            my $res = $cb($req);
            if !is $res.code, 200 {
                return
            }
            if !is $res.content.decode, "COUNTER=>$i" {
                return
            }
        }, "counter increment ($i)";
    }

    subtest {
        my $req = HTTP::Request.new(GET => "http://localhost/logout");
        $req.field(|{"Cookie" => "myapp-session=$first-cookie"});
        my $res = $cb($req);
        if !is $res.code, 200 {
            $res.content.decode.say;
            return
        }

        my $set-cookie = $res.field("Set-Cookie");
        if !ok $set-cookie.defined, "cookie header should be defined" {
            return
        }
        like $set-cookie.Str, rx/"myapp-session=" (<[0..9,a..f]>**40) ";"/;

        $res = $cb(HTTP::Request.new(GET => "http://localhost/"));
        if !is $res.code, 200 {
            $res.content.decode.say;
            return
        }
        if !is $res.content.decode, "TOP" {
            $res.content.decode.say;
            return
        }
        $set-cookie = $res.field("Set-Cookie");
        if !ok $set-cookie.defined, "cookie header should be defined" {
            return
        }
        $set-cookie.Str ~~ /"myapp-session=" (<[0..9,a..f]>**40) ";"/;
        isnt $first-cookie, $/[0], "cookie should be different";
    }, "logout";
});

done-testing;


=begin pod

        {
            my $res = $ua->request(GET "http://localhost:$port/counter");
            is($res->content, "counter=>1");
        }

        {
            my $res = $ua->request(GET "http://localhost:$port/counter");
            is($res->content, "counter=>2");
        }

        {
            my $res = $ua->request(GET "http://localhost:$port/logout");
            is($res->content, "LOGOUT");
            ok($res->header("Set-Cookie") =~ qr/myapp_session=([a-f0-9]{40});/);
            is($1, $first_cookie);
        }

        {
            my $res = $ua->request(GET "http://localhost:$port/");
            is($res->content, "TOP");
            ok($res->header("Set-Cookie") =~ qr/myapp_session=([a-f0-9]{40});/);
            isnt($1, $first_cookie);
        }

        {
            my $res = $ua->request(GET "http://localhost:$port/counter");
            is($res->content, "counter=>1");
        }

    }
);

done_testing;

=end pod

