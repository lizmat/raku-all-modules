use v6;
use Test;
use Apache::LogFormat::Compiler;

my $f = Apache::LogFormat::Compiler.new();

my $fmt = $f.compile(
    '%z %{HTTP_X_FORWARDED_FOR|REMOTE_ADDR}Z',
    {'Z' => sub ($block, %env, @res, $length, $reqtime) {
        is($block, 'HTTP_X_FORWARDED_FOR|REMOTE_ADDR');
        ok(%env, 'Z - $env');
        ok(@res, 'Z - @res');
        return $block;
    }},
    {'z' => sub (%env, @res) {
        ok(%env, 'z - $env');
        ok(@res, 'z - @res');
        return %env<HTTP_X_REQ_TEST>;
    }},
);
note "ok";
if ! ok($fmt, "f is valid") {
    return
}
if ! isa-ok($fmt, "Apache::LogFormat::Formatter") {
    return
}

my %env = (
    HTTP_X_REQ_TEST => "foo",
);
my @res = (
    200,
    ["X-Res-Test" => "bar"],
    ["OK"],
);
my $t0 = DateTime.now.Instant;
sleep 1;
my $now = DateTime.now;
my $got = $fmt.format(%env, @res, 10, $t0 - $now.Instant, $now);

if ! ok($got ~~ m!'foo HTTP_X_FORWARDED_FOR|REMOTE_ADDR'!, "line is as expected") {
    note $got;
    return;
}

done-testing;
