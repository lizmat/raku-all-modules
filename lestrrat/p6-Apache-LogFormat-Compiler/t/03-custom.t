use v6;
use Test;
use Apache::LogFormat::Compiler;

my $f = Apache::LogFormat::Compiler.new();
my $fmt = $f.compile('%{Content-Length}i %{Content-Type}i %{Content-Type}o %{Content-Length}o');
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
    CONTENT_TYPE => "application/x-www-form-urlencoded",
    CONTENT_LENGTH => 7,
);
my @res = (
    200,
    ["Content-Type" => "text/plain", "Content-Length" => 2],
    ["OK"],
);
my $t0 = DateTime.now.Instant;
sleep 1;
my $now = DateTime.now;
my $got = $fmt.format(%env, @res, 10, $t0 - $now.Instant, $now);

if ! ok($got ~~ m!'7 application/x-www-form-urlencoded text/plain 2'!, "line is as expected") {
    note $got;
    return;
}

done-testing;