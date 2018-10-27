use v6;
use Test;
use Apache::LogFormat;

use lib 't/lib';
use Apache::LogFormat::TestUtil;

my $fmt = Apache::LogFormat.combined();
isa-ok $fmt, "Apache::LogFormat::Formatter"
    or return;

my $got = test-format $fmt;

like $got, rx/ ^ "192.168.1.1 - foo " <timefmt> ' "GET /foo/bar/baz HTTP/1.0" 200 ' \d+ ' "http://doc.perl6.org" "Firefox foo blah\x0a"' /, "line matches"
    or return;

done-testing;
