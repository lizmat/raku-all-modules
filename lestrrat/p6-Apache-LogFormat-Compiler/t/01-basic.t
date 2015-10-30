use v6;
use Test;
use Apache::LogFormat::Compiler;

my $f = Apache::LogFormat::Compiler.new();
my $fmt = $f.compile('%r %t "%{User-agent}i"');
if ! ok($fmt, "f is valid") {
    return
}

if ! isa-ok($fmt, "Apache::LogFormat::Formatter") {
    return
}

my %env = (
    HTTP_USER_AGENT => "Firefox foo blah\n",
    REQUEST_METHOD => "GET",
    REQUEST_URI => "/foo/bar/baz",
    SERVER_PROTOCOL => "HTTP/1.0",
);
my @res = (200, ["Content-Type" => "text/plain"], ["Hello, World".encode('ascii')]);
my $t0 = DateTime.now.Instant;
sleep 1;
my $now = DateTime.now;
my $got = $fmt.format(%env, @res, 10, $t0 - $now.Instant, $now);

if ! ok($got ~~ m!'GET /foo/bar/baz HTTP/1.0'!, "Checking %r") {
    note $got;
    return;
}

if ! ok($got ~~ m!\[\d**2\/<[A..Z]><[a..z]>**2\/\d**4\:\d**2\:\d**2\:\d**2 " " <[\+\-]>\d**4\]!, "checking %t") {
    note $got;
    return;
}

if ! ok($got ~~ /'"Firefox foo blah\\x0a"'/, "line is as expected") {
    note $got;
    return;
}

done-testing;
