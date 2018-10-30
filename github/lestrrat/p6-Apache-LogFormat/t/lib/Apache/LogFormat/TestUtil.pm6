use v6;
unit module Apache::LogFormat::TestUtil;

my token date { \d ** 2 '/' <[A..Z]><[a..z]> ** 2 '/' \d ** 4 }
my token time { [\d ** 2] ** 3 % ':' }
my token zone { <[+-]> \d ** 4 }
my token timefmt is export { '[' <date> ':' <time> ' ' <zone> ']' }

my %def_env = (
    HTTP_REFERER => "http://doc.perl6.org",
    HTTP_USER_AGENT => "Firefox foo blah\n",
    REMOTE_ADDR => "192.168.1.1",
    REMOTE_USER => "foo",
    REQUEST_METHOD => "GET",
    REQUEST_URI => "/foo/bar/baz",
    SERVER_PROTOCOL => "HTTP/1.0",
);
my @def_res = (200, ["Content-Type" => "text/plain"], ["Hello, World".encode('ascii')]);

sub test-format($fmt, :%env is copy, :@res = @def_res, :$now = DateTime.now, :$tz) is export {
    if %env {
        %env{ .key } //= .value for %def_env.pairs;
    }
    else {
        %env := %def_env;
    }
    $fmt.format(%env, @res, 10, Duration.new(1), $tz.defined ?? $now.in-timezone($tz) !! $now);
}
