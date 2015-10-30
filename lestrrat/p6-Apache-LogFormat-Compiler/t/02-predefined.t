use v6;
use Test;
use Apache::LogFormat;

my $fmt = Apache::LogFormat.combined();
if ! isa-ok($fmt, "Apache::LogFormat::Formatter") {
    return
}

my %env = (
    HTTP_REFERER => "http://doc.perl6.org",
    HTTP_USER_AGENT => "Firefox foo blah\n",
    REMOTE_ADDR => "192.168.1.1",
    REMOTE_USER => "foo",
    REQUEST_METHOD => "GET",
    REQUEST_URI => "/foo/bar/baz",
    SERVER_PROTOCOL => "HTTP/1.0",
);
my @res = (200, ["Content-Type" => "text/plain"], ["Hello, World".encode('ascii')]);
my $t0 = DateTime.now.Instant;
sleep 1;
my $now = DateTime.now;
my $got = $fmt.format(%env, @res, 10, $t0 - $now.Instant, $now);

if !ok $got ~~ /^ "192.168.1.1 - foo [" \d**2\/<[A..Z]><[a..z]>**2\/\d**4\:\d**2\:\d**2\:\d**2 " " <[\+\-]>\d**4 '] "GET /foo/bar/baz HTTP/1.0" 200 ' \d+ ' "http://doc.perl6.org" "Firefox foo blah\x0a"' /, "line matches" {
    note $got;
}
done-testing;
