use v6;
use Test;
use Apache::LogFormat::Compiler;

use lib 't/lib';
use Apache::LogFormat::TestUtil;

my $f = Apache::LogFormat::Compiler.new();
my $fmt = $f.compile('%r %t "%{User-agent}i"');
ok $fmt, "f is valid"
    or return;

isa-ok $fmt, "Apache::LogFormat::Formatter"
    or return;

my $got = test-format $fmt;

like $got, rx!'GET /foo/bar/baz HTTP/1.0'!, "checking %r"
    or return;

# Check with various timezones
for Nil, -21600, 32400, 0 -> $tz {
    my $tag = '';
    my $got2 = $got;
    if $tz.defined {
        $tag = " (tz: $tz)";
        $got2 = test-format $fmt, :$tz;
    }
    like $got2, rx/<timefmt>/, "checking %t$tag"
        or return;
}

like $got, rx/'"Firefox foo blah\\x0a"'/, "line is as expected"
    or return;

done-testing;
