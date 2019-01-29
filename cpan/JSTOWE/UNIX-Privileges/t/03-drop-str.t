use v6;

use Test;

use UNIX::Privileges;

plan 3;

if +$*USER != 0 {
    skip 'these tests must be run as root', 3;
    exit;
}

try {
    UNIX::Privileges::userinfo("nobody");
}

if $! {
    skip-rest 'these tests require a user named "nobody"', 3;
    exit;
}

my $file = "03-drop-str";
unlink($file);

spurt($file, "all mimsy were the borogoves\n");

my $dp;
lives-ok { $dp = UNIX::Privileges::drop("nobody"); }, 'drop privileges lived';

ok $dp, 'drop privileges succeeded';

my $content = "58f149ce85e23a24df6313c8198e37abab7d7f6c";

if $file.IO.e {
    dies-ok { spurt($file, $content) }, 'cannot write to file owned by root';
}

# vim: ft=perl6
