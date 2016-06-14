use v6;
use Test;
use HTTP::Tinyish;
use File::Temp;
use JSON::Fast;

my %res = await HTTP::Tinyish.new(:async).get("http://www.cpan.org");
is %res<status>, 200;
like %res<content>, rx/Comprehensive/;

%res = await HTTP::Tinyish.new(:async, verify-ssl => True).get("https://github.com/");
is %res<status>, 200;
like %res<content>, rx:i/github/;

%res = await HTTP::Tinyish.new(:async, verify-ssl => False).get("https://cpan.metacpan.org/");
is %res<status>, 200;
like %res<content>, rx:i/Comprehensive/;

%res = await HTTP::Tinyish.new(:async).head("http://httpbin.org/headers");
is %res<status>, 200;

%res = await HTTP::Tinyish.new(:async).post: "http://httpbin.org/post",
    headers => { 'Content-Type' => 'application/x-www-form-urlencoded' },
    content => "foo=1&bar=2",
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<form>, { foo => "1", bar => "2" };

my @data = "xyz\n", "xyz";
%res = await HTTP::Tinyish.new(:async, timeout => 1).post: "http://httpbin.org/post",
    headers => { 'Content-Type' => 'application/octet-stream' },
    content => sub { @data.shift },
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<data>, "xyz\nxyz";

%res = await HTTP::Tinyish.new(:async).put: "http://httpbin.org/put",
    headers => { 'Content-Type' => 'text/plain' },
    content => "foobarbaz",
;
is %res<status>, 200;
is-deeply from-json(%res<content>)<data>, "foobarbaz";

%res = await HTTP::Tinyish.new(:async, default-headers => { "Foo" => "Bar", Dnt => "1" })\
    .get("http://httpbin.org/headers", headers => { "Foo" => ["Bar", "Baz"] });
is from-json(%res<content>)<headers><Foo>, "Bar,Baz";
is from-json(%res<content>)<headers><Dnt>, "1";

my $fn = tempdir() ~ "/index.html";
%res = await HTTP::Tinyish.new(:async).mirror("http://www.cpan.org", $fn);
is %res<status>, 200;
like $fn.IO.slurp, rx/Comprehensive/;

%res = await HTTP::Tinyish.new(:async).mirror("http://www.cpan.org", $fn);
is %res<status>, 304;
is %res<success>, True;

%res = await HTTP::Tinyish.new(:async, agent => "Menlo/1").get("http://httpbin.org/user-agent");
is-deeply from-json(%res<content>), { 'user-agent' => "Menlo/1" };

%res = await HTTP::Tinyish.new(:async).get("http://httpbin.org/status/404");
is %res<status>, 404;
is %res<reason>, "NOT FOUND";
is %res<success>, False;

%res = await HTTP::Tinyish.new(:async).get("http://httpbin.org/response-headers?Foo=Bar+Baz");
is %res<headers><foo>, "Bar Baz";

%res = await HTTP::Tinyish.new(:async).get("http://httpbin.org/basic-auth/user/passwd");
is %res<status>, 401;

%res = await HTTP::Tinyish.new(:async).get("http://user:passwd@httpbin.org/basic-auth/user/passwd");
is %res<status>, 200;
is-deeply from-json(%res<content>), { authenticated => True, user => "user" };

%res = await HTTP::Tinyish.new(:async).get("http://httpbin.org/redirect/1");
is %res<status>, 200;

%res = await HTTP::Tinyish.new(:async, max-redirect => 2).get("http://httpbin.org/redirect/3");
isnt %res<status>, 200; # either 302 or 599

%res = await HTTP::Tinyish.new(:async, timeout => 1).get("http://httpbin.org/delay/2");
like %res<status>.Str, rx/^5/;

%res = await HTTP::Tinyish.new(:async).get("http://httpbin.org/encoding/utf8");
like %res<content>, rx/コンニチハ/;

done-testing;
