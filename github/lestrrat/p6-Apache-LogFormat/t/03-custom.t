use v6;
use Test;
use Apache::LogFormat::Compiler;

use lib 't/lib';
use Apache::LogFormat::TestUtil;

my $f = Apache::LogFormat::Compiler.new();
my $fmt = $f.compile('%{Content-Length}i %{Content-Type}i %{Content-Type}o %{Content-Length}o');
ok $fmt, "f is valid"
    or return;

isa-ok $fmt, "Apache::LogFormat::Formatter"
    or return;

my @res = (
    200,
    ["Content-Type" => "text/plain", "Content-Length" => 2],
    ["OK"],
);
my %env = (
    CONTENT_TYPE => "application/x-www-form-urlencoded",
    CONTENT_LENGTH => 7,
);
my $got = test-format $fmt, :%env, :@res;

like $got, rx!'7 application/x-www-form-urlencoded text/plain 2'!, "line is as expected"
    or return;

done-testing;
