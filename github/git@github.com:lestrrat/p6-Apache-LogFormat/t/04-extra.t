use v6;
use Test;
use Apache::LogFormat::Compiler;

use lib 't/lib';
use Apache::LogFormat::TestUtil;

my $f = Apache::LogFormat::Compiler.new();

my $fmt = $f.compile(
    '%z %{HTTP_X_FORWARDED_FOR|REMOTE_ADDR}Z',
    {'Z' => sub ($block, %env, @res, $length, $reqtime) {
        is $block, 'HTTP_X_FORWARDED_FOR|REMOTE_ADDR', "Z - block";
        ok %env, 'Z - $env';
        ok @res, 'Z - @res';
        return $block;
    }},
    {'z' => sub (%env, @res) {
        ok %env, 'z - $env';
        ok @res, 'z - @res';
        return %env<HTTP_X_REQ_TEST>;
    }},
);

pass "alive after compile";

ok $fmt, "f is valid"
    or return;
isa-ok $fmt, "Apache::LogFormat::Formatter"
    or return;

my %env = (
    HTTP_X_REQ_TEST => "foo",
);
my @res = (
    200,
    ["X-Res-Test" => "bar"],
    ["OK"],
);
my $got = test-format $fmt, :%env, :@res;

like $got, rx!'foo HTTP_X_FORWARDED_FOR|REMOTE_ADDR'!, "line is as expected"
    or return;

done-testing;
