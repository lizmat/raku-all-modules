use v6;
use Test;
use HTTP::Tinyish;
use File::Temp;
use JSON::Fast;

my %res = HTTP::Tinyish.new.get("http://www.cpan.org");
is %res<status>, 200;
like %res<content>, rx/Comprehensive/;

%res = HTTP::Tinyish.new(verify-ssl => True).get("https://github.com/");
is %res<status>, 200;
like %res<content>, rx:i/github/;

# for status line like HTTP/2
%res = HTTP::Tinyish.new(verify-ssl => True).get("https://www.youtube.com/");
is %res<status>, 200;
like %res<content>, rx:i/google.com/;

%res = HTTP::Tinyish.new(verify-ssl => False).get("https://cpan.metacpan.org/");
is %res<status>, 200;
like %res<content>, rx:i/Comprehensive/;

%res = HTTP::Tinyish.new.head("http://httpbin.org/headers");
is %res<status>, 200;

%res = HTTP::Tinyish.new.post: "http://httpbin.org/post",
    headers => { 'Content-Type' => 'application/x-www-form-urlencoded' },
    content => "foo=1&bar=2",
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<form>, { foo => "1", bar => "2" };

my @data = "xyz\n", "xyz";
%res = HTTP::Tinyish.new(timeout => 1).post: "http://httpbin.org/post",
    headers => { 'Content-Type' => 'application/octet-stream' },
    content => sub { @data.shift },
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<data>, "xyz\nxyz";

%res = HTTP::Tinyish.new.put: "http://httpbin.org/put",
    headers => { 'Content-Type' => 'text/plain' },
    content => "foobarbaz",
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<data>, "foobarbaz";

%res = HTTP::Tinyish.new(default-headers => { "Foo" => "Bar", Dnt => "1" })\
    .get("http://httpbin.org/headers", headers => { "Foo" => ["Bar", "Baz"] });
is from-json(%res<content>)<headers><Foo>, "Bar,Baz";
is from-json(%res<content>)<headers><Dnt>, "1";

my $fn = tempdir() ~ "/index.html";
%res = HTTP::Tinyish.new.mirror("http://www.cpan.org", $fn);
is %res<status>, 200;
like $fn.IO.slurp, rx/Comprehensive/;

%res = HTTP::Tinyish.new.mirror("http://www.cpan.org", $fn);
is %res<status>, 304;
is %res<success>, True;

%res = HTTP::Tinyish.new(agent => "Menlo/1").get("http://httpbin.org/user-agent");
is-deeply from-json(%res<content>), { 'user-agent' => "Menlo/1" };

%res = HTTP::Tinyish.new.get("http://httpbin.org/status/404");
is %res<status>, 404;
is %res<reason>, "NOT FOUND";
is %res<success>, False;

%res = HTTP::Tinyish.new.get("http://httpbin.org/response-headers?Foo=Bar+Baz");
is %res<headers><foo>, "Bar Baz";

%res = HTTP::Tinyish.new.get("http://httpbin.org/basic-auth/user/passwd");
is %res<status>, 401;

%res = HTTP::Tinyish.new.get("http://user:passwd@httpbin.org/basic-auth/user/passwd");
is %res<status>, 200;
is-deeply from-json(%res<content>), { authenticated => True, user => "user" };

%res = HTTP::Tinyish.new.get("http://httpbin.org/redirect/1");
is %res<status>, 200;

%res = HTTP::Tinyish.new(max-redirect => 2).get("http://httpbin.org/redirect/3");
isnt %res<status>, 200; # either 302 or 599

%res = HTTP::Tinyish.new(timeout => 1).get("http://httpbin.org/delay/2");
like %res<status>.Str, rx/^5/;

%res = HTTP::Tinyish.new.get("http://httpbin.org/encoding/utf8");
like %res<content>, rx/コンニチハ/;

done-testing;
